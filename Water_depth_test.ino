#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266WebServer.h>
#include <ArduinoJson.h>
#include <HCSR04.h>
#include "time.h"

// --- Network credentials ---
#define WIFI_SSID "Mun Teng"
#define WIFI_PASSWORD "196831nmt"

// --- Destination server (Raspberry Pi) ---
const char* pi_server = "10.187.208.20";
const int pi_port = 5000;

// --- Timing ---
unsigned long lastSendTime = 0;
const unsigned long sendInterval = 1000;

// --- NTP ---
const char* ntpServer = "pool.ntp.org";

// --- Ultrasonic ---
const int trigPin = 12;  // D6
const int echoPin = 14;  // D5
const double cupHeight = 32.0;

// --- Soil reference ---
const double belowSoilDepth = 22.0;
const double soilSurfaceDistance = cupHeight - belowSoilDepth;

// --- Measurements ---
double distance, levelFromSoil;

// ✅ Mobile data
String uid = "";
String plantingMethod = "";
int days = 0;
String growthStage = "";
double rainfall_mm = 0;
int user_control = -1;

// --- Devices ---
UltraSonicDistanceSensor distanceSensor(trigPin, echoPin);
ESP8266WebServer server(80);

// --- WiFi ---
void initWiFi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  Serial.print("Connecting to WiFi");

  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 20000) {
    Serial.print(".");
    delay(500);
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println();
    Serial.print("WiFi connected, IP: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\nWiFi failed");
  }
}

// --- Time ---
String getFormattedTime() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) return "unknown";
  char buffer[30];
  strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", &timeinfo);
  return String(buffer);
}

// --- Distance ---
double getAverageDistance(int samples) {
  double total = 0;
  int valid = 0;
  for (int i = 0; i < samples; i++) {
    double d = distanceSensor.measureDistanceCm();
    if (d >= 0 && d < 400) {
      total += d;
      valid++;
    }
    delay(50);
  }
  return valid ? total / valid : -1;
}

// --- Receive data from Flutter ---
void handleUpdateData() {
  if (!server.hasArg("plain")) {
    server.send(400, "application/json", "{\"error\":\"no data\"}");
    return;
  }

  String body = server.arg("plain");
  DynamicJsonDocument doc(256);
  if (deserializeJson(doc, body)) {
    server.send(400, "application/json", "{\"error\":\"invalid JSON\"}");
    return;
  }

  uid = doc["uid"].as<String>();

  if (doc.containsKey("planting_method")) {
    plantingMethod = doc["planting_method"].as<String>();
  } else {
    plantingMethod = doc["plantingMethod"].as<String>();
  }

  days = doc["days"];

  if (doc.containsKey("growth_stage")) {
    growthStage = doc["growth_stage"].as<String>();
  } else {
    growthStage = doc["growthStage"].as<String>();
  }

  rainfall_mm = doc["rainfall_mm"];

  if (doc.containsKey("user_control")) {
    user_control = doc["user_control"];
  } else {
    user_control = doc["userControl"];
  }

  server.send(200, "application/json", "{\"status\":\"updated\"}");
  Serial.println("Updated mobile data: " + body);

  if (user_control == 0 || user_control == 1) {
    sendToPi(levelFromSoil, getFormattedTime());
    user_control = -1;
  }
}

// --- Send to Raspberry Pi ---
void sendToPi(double levelFromSoil, const String& timeStr) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi not connected");
    return;
  }

  if (uid == "") {
    Serial.println("UID missing, not sending");
    return;
  }

  WiFiClient client;

  if (!client.connect(pi_server, pi_port)) {
    Serial.println("Cannot connect to Raspberry Pi");
    return;
  }
  client.stop();

  HTTPClient http;
  String url = "http://" + String(pi_server) + ":" + String(pi_port) + "/esp";

  Serial.println("Connecting to: " + url);
  if (!http.begin(client, url)) {
    Serial.println("HTTP begin failed");
    return;
  }

  http.addHeader("Content-Type", "application/json");

  DynamicJsonDocument doc(256);
  doc["uid"] = uid;
  doc["planting_method"] = plantingMethod;
  doc["days"] = days;
  doc["growth_stage"] = growthStage;
  doc["rainfall_mm"] = rainfall_mm;
  doc["current_water_level"] = levelFromSoil;
  doc["timestamp"] = timeStr;
  doc["user_control"] = user_control;

  String payload;
  serializeJson(doc, payload);

  Serial.println("Sending to Pi:");
  Serial.println(payload);

  int httpCode = http.POST(payload);
  Serial.print("HTTP code: ");
  Serial.println(httpCode);

  if (httpCode > 0) {
    Serial.println(http.getString());
  } else {
    Serial.println("POST failed");
  }

  http.end();
}

// --- Setup ---
void setup() {
  Serial.begin(115200);
  initWiFi();

  configTime(8 * 3600, 0, ntpServer);
  Serial.print("Waiting for NTP");

  struct tm timeinfo;
  while (!getLocalTime(&timeinfo)) {
    Serial.print(".");
    delay(500);
  }
  Serial.println("\nNTP synced!");

  server.on("/update_mobile_data", HTTP_POST, handleUpdateData);
  server.begin();
}

// --- Loop ---
void loop() {
  server.handleClient();

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected! Reconnecting...");
    initWiFi();
  }

  distance = getAverageDistance(10);
  if (distance >= 0 && distance <= cupHeight) {
    levelFromSoil = soilSurfaceDistance - distance;
    Serial.print("Level: ");
    Serial.println(levelFromSoil);
  }

  if (millis() - lastSendTime >= sendInterval) {
    lastSendTime = millis();
    if (plantingMethod != "" && growthStage != "" && uid != "") {
      sendToPi(levelFromSoil, getFormattedTime());
    } else {
      Serial.println("Waiting for mobile data...");
    }
  }

  delay(1000);
}
