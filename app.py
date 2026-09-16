from flask import Flask, request, jsonify
import joblib, numpy as np, os, time, RPi.GPIO as GPIO
import pandas as pd
import firebase_admin
from firebase_admin import credentials, db

# --- Config / paths ---
MODEL_PATH = "/home/ngmt3/irrigation_xgb_model.pkl"
ENCODER_PATH = "/home/ngmt3/label_encoders.pkl"
CRED_PATH = "/home/ngmt3/awd-irrigation-firebase-adminsdk-fbsvc-a71d4d25f1.json"
LOG_FILE = "/home/ngmt3/irrigation_log.csv"
PHASE_FILE = "/home/ngmt3/irrigation_phase.txt"
DEFAULT_THRESHOLD_CM = 5.0
MANUAL_TTL_SEC = 60

# --- Firebase ---
cred = credentials.Certificate(CRED_PATH)
if not firebase_admin._apps:
    firebase_admin.initialize_app(
        cred,
        {"databaseURL": "https://awd-irrigation-default-rtdb.asia-southeast1.firebasedatabase.app"},
    )

def get_user_ref(uid: str):
    if not uid:
        raise ValueError("Missing uid")
    return db.reference(f"irrigation_data/{uid}")

# --- Flask ---
app = Flask(__name__)

# --- GPIO setup ---
GPIO.setmode(GPIO.BCM)
RELAY_PIN = 17
GPIO.setup(RELAY_PIN, GPIO.OUT)
GPIO.output(RELAY_PIN, GPIO.LOW)

class IrrigationModelWithThreshold:
    """
    Compatibility shim for a model that was saved via joblib with a custom wrapper
    class defined in a notebook/kernel (__main__). When unpickling, Python needs
    to find this name on the running __main__ module (this file).

    The wrapper returns an array of [decision, threshold] for each row.
    """

    def __init__(
        self,
        model,
        le_method,
        le_phase,
        le_stage,
        thresholds,
        default_flood=5.0,
        default_dry=-15.0,
    ):
        self.model = model
        self.le_method = le_method
        self.le_phase = le_phase
        self.le_stage = le_stage
        self.thresholds = thresholds
        self.default_flood = default_flood
        self.default_dry = default_dry

    def _compute_threshold(self, method: str, stage: str, phase: str) -> float:
        if method in self.thresholds and stage in self.thresholds[method]:
            return float(self.thresholds[method][stage])
        return float(self.default_flood if phase == "Flooding" else self.default_dry)

    def predict(self, X):
        # Accept DataFrame or array-like with the same column order used in training.
        if isinstance(X, pd.DataFrame):
            arr = X[
                [
                    "Method",
                    "Days",
                    "GrowthStage",
                    "Rainfall_mm",
                    "CurrentWaterLevel_cm",
                    "IrrigationPhase",
                ]
            ].to_numpy()
        else:
            arr = np.asarray(X)

        decisions = self.model.predict(arr)

        method_codes = arr[:, 0].astype(int)
        stage_codes = arr[:, 2].astype(int)
        phase_codes = arr[:, 5].astype(int)

        methods = self.le_method.inverse_transform(method_codes)
        stages = self.le_stage.inverse_transform(stage_codes)
        phases = self.le_phase.inverse_transform(phase_codes)

        outputs = []
        for dec, meth, stg, ph in zip(decisions, methods, stages, phases):
            thr = self._compute_threshold(meth, stg, ph)
            outputs.append([int(dec), float(thr)])
        return np.asarray(outputs)

# If the pickle references __main__.IrrigationModelWithThreshold (common when saved from a notebook),
# make it available there even when this file is imported as a module (e.g., via `flask run`).
import sys as _sys
setattr(_sys.modules.get("__main__", _sys), "IrrigationModelWithThreshold", IrrigationModelWithThreshold)

def _predict_decision_and_threshold(features: np.ndarray):
    pred = model.predict(features)
    threshold = None

    if isinstance(pred, (list, tuple, np.ndarray)):
        first = pred[0]
        if isinstance(first, (list, tuple, np.ndarray)) and len(first) >= 2:
            decision = int(first[0])
            threshold = _parse_float(first[1], None)
        elif isinstance(first, dict):
            decision = int(first.get("decision", first.get("label", 0)))
            threshold = _parse_float(first.get("threshold"), None)
        else:
            decision = int(first)
    elif isinstance(pred, dict):
        decision = int(pred.get("decision", pred.get("label", 0)))
        threshold = _parse_float(pred.get("threshold"), None)
    else:
        decision = int(pred)

    return decision, threshold

# --- Model + encoders ---
model = joblib.load(MODEL_PATH)
le_method, le_phase, le_stage = joblib.load(ENCODER_PATH)

last_manual_ts = 0  # epoch seconds of last manual toggle

def save_last_phase(phase: str) -> None:
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    with open(PHASE_FILE, "w") as f:
        f.write(f"{phase},{timestamp}")

def read_last_phase() -> str:
    if os.path.exists(PHASE_FILE):
        with open(PHASE_FILE, "r") as f:
            content = f.read().strip()
            if "," in content:
                phase, _ = content.split(",", 1)
                return phase
            return content or "Flooding"
    return "Flooding"

def update_phase(water_level: float) -> str:
    last_phase = read_last_phase()
    if last_phase == "Flooding" and water_level >= 5:
        new_phase = "Drying"
    elif last_phase == "Drying" and water_level <= -15:
        new_phase = "Flooding"
    else:
        new_phase = last_phase

    if new_phase != last_phase:
        save_last_phase(new_phase)
        print(f"Phase changed to {new_phase} at {time.strftime('%Y-%m-%d %H:%M:%S')}")
    return new_phase

def log_data(data_dict: dict) -> None:
    df = pd.DataFrame([data_dict])
    file_exists = os.path.isfile(LOG_FILE)
    df.to_csv(LOG_FILE, mode="a", header=not file_exists, index=False)

def push_log(record: dict, uid: str) -> None:
    get_user_ref(uid).push(record)

def _parse_float(val, default=0.0):
    try:
        return float(val)
    except (TypeError, ValueError):
        return default

def _safe_label(le, value, fallback):
    # Be resilient to unexpected labels coming from the client/device.
    try:
        if value in getattr(le, "classes_", []):
            return le.transform([value])[0]
        if fallback in getattr(le, "classes_", []):
            return le.transform([fallback])[0]
        # Last resort: pick the first known class.
        return le.transform([le.classes_[0]])[0]
    except Exception:
        return 0

@app.route("/esp", methods=["POST"])
def receive_esp_data():
    try:
        data = request.get_json(silent=True) or {}
        print("Received ESP Data:", data)

        uid = data.get("uid")
        if not uid:
            return jsonify({"error": "uid is required"}), 400

        now = time.time()

        method = data.get("plantingMethod")
        stage = data.get("growthStage")
        days = int(data.get("days", 0))
        rainfall_mm = _parse_float(data.get("rainfall_mm"))
        water_level = _parse_float(
            data.get("currentWaterLevel")
        )

        raw_uc = data.get("user_control", data.get("userControl", -1))
        try:
            user_control = int(raw_uc)
        except (TypeError, ValueError):
            user_control = -1

        normalized = {
            "uid": uid,
            "planting_method": method,
            "days": days,
            "growth_stage": stage,
            "rainfall_mm": rainfall_mm,
            "current_water_level": water_level,
            "timestamp": data.get("timestamp"),
        }

        global last_manual_ts
        if user_control in (0, 1):
            last_manual_ts = now

        manual_valid = user_control in (0, 1) and (now - last_manual_ts) <= MANUAL_TTL_SEC

        threshold_cm = None
        if manual_valid:
            decision = user_control
            phase = "User Control"
        else:
            user_control = -1
            phase = update_phase(water_level)
            method_enc = _safe_label(le_method, method, "AWD")
            stage_enc = _safe_label(le_stage, stage, "Tillering")
            phase_enc = _safe_label(le_phase, phase, "Flooding")
            features = np.array([[method_enc, days, stage_enc, rainfall_mm, water_level, phase_enc]])
            decision, threshold_cm = _predict_decision_and_threshold(features)

        if threshold_cm is None:
            threshold_cm = DEFAULT_THRESHOLD_CM

        normalized["user_control"] = user_control

        GPIO.output(RELAY_PIN, GPIO.HIGH if decision == 1 else GPIO.LOW)
        status = "ON" if decision == 1 else "OFF"

        record = {
            "date": time.strftime("%Y-%m-%d"),
            "time": time.strftime("%H:%M:%S"),
            **normalized,
            "manual_valid": manual_valid,
            "irrigation_phase": phase,
            "decision": decision,
            "status": status,
            "threshold": threshold_cm,
        }
        log_data(record)
        push_log(record, uid)
        print("🚰", status, "(manual override)" if manual_valid else "(auto)")
        return jsonify(record), 200

    except Exception as e:
        print("❌ Error:", e)
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
