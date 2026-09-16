"""Train the irrigation XGBoost classifier with clear structure for thesis documentation."""

from __future__ import annotations

import joblib
import pandas as pd
import xgboost as xgb
from pathlib import Path
from sklearn.metrics import accuracy_score, classification_report
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder


WATER_THRESHOLDS = {
    "Transplanting": {
        "Transplanting": 5,
        "Flowering": 5,
    },
    "Direct Seeding": {
        "Germination": 5,
        "Emergence": 3,
        "Flowering": 5,
    },
}


def load_data(path: str = "simulated_rice_irrigation_data.csv") -> pd.DataFrame:
    """Read the generated irrigation dataset and return a DataFrame."""
    data_path = Path(path)
    if not data_path.exists():
        raise FileNotFoundError(
            "Dataset not found. Run the data generation cell or script to create simulated_rice_irrigation_data.csv"
        )

    return pd.read_csv(data_path)


def encode_labels(df: pd.DataFrame) -> tuple[pd.DataFrame, tuple[LabelEncoder, LabelEncoder, LabelEncoder]]:
    """Encode the categorical columns needed for XGBoost and return encoders."""
    le_method = LabelEncoder().fit(df["Method"])
    df["Method"] = le_method.transform(df["Method"])

    le_stage = LabelEncoder().fit(df["GrowthStage"])
    df["GrowthStage"] = le_stage.transform(df["GrowthStage"])

    le_phase = LabelEncoder().fit(df["IrrigationPhase"])
    df["IrrigationPhase"] = le_phase.transform(df["IrrigationPhase"])

    return df, (le_method, le_stage, le_phase)


def split_features(df: pd.DataFrame) -> tuple[pd.DataFrame, pd.Series]:
    """Extract feature matrix X and target vector y from the dataframe."""
    feature_cols = [
        "Method",
        "Days",
        "GrowthStage",
        "Rainfall_mm",
        "CurrentWaterLevel_cm",
        "IrrigationPhase",
    ]
    X = df[feature_cols]
    y = df["IrrigationNeeded"]
    return X, y


def build_model() -> xgb.XGBClassifier:
    """Instantiate the XGBoost classifier with thesis-ready hyperparameters."""
    return xgb.XGBClassifier(
        n_estimators=200,
        learning_rate=0.1,
        max_depth=5,
        random_state=42,
        use_label_encoder=False,
        eval_metric="logloss",
    )


def evaluate_model(model, X_test, y_test) -> None:
    """Print accuracy and classification metrics for documentation."""
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    print(f"Test accuracy: {accuracy:.4f}")
    print("Classification report:\n", classification_report(y_test, y_pred, zero_division=0))


def save_artifacts(model, encoders: tuple[LabelEncoder, LabelEncoder, LabelEncoder]) -> None:
    """Persist the trained model and encoders for future inference."""
    joblib.dump(model, "irrigation_xgb_model.pkl")
    joblib.dump(encoders, "label_encoders.pkl")


def main() -> None:
    df = load_data()
    df_encoded, encoders = encode_labels(df)
    X, y = split_features(df_encoded)

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    model = build_model()
    model.fit(X_train, y_train)

    evaluate_model(model, X_test, y_test)
    save_artifacts(model, encoders)

    total = len(y)
    positive = int(y.sum())
    negative = total - positive
    print(f"Data summary: {total} samples ({positive} irrigation-on, {negative} irrigation-off)")


if __name__ == "__main__":
    main()
