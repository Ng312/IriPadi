import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/database/database_service.dart';
import 'package:flutter_application_1/widgets/growthStage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormDataProvider with ChangeNotifier {
  FormDataProvider() {
    _initIrrigationListener();
    _hydrateFromStorage();
  }

  // ESP8266/ESP12F HTTP server host (port 80).
  // Update this when the device IP changes on your WiFi network.
  static const String _espHost = '10.187.208.94';

  static const _methodKey = 'field_method';
  static const _locationKey = 'field_location';
  static const _startDateKey = 'field_start_date';
  static const _latKey = 'field_lat';
  static const _lonKey = 'field_lon';
  static const _setupCompleteKey = 'field_setup_complete';

  String? method;
  String? location;
  double? latitude;
  double? longitude;
  DateTime? startDate;
  int? days;
  String? growthStage;
  double? rainfallMM;
  int pumpStatus = 0; // 0 = off, 1 = on
  int userControl = -1; // -1 = auto, 0/1 = manual override
  bool manualOverride = false;

  String? irrigationStatus;
  bool isLoading = false;
  bool _sendingEnabled = false;
  bool _sendQueued = false;
  String? _lastSentBody;
  final DatabaseService _dbService = DatabaseService();
  StreamSubscription<DatabaseEvent>? _irrigationSub;
  bool _manualInFlight = false;
  bool _hydrated = false;
  bool deviceConnected = false;

  bool get isHydrated => _hydrated;
  bool get hasSavedFieldData =>
      method != null &&
      startDate != null &&
      location != null &&
      latitude != null &&
      longitude != null;

  void _initIrrigationListener() {
    if (_irrigationSub != null) return;
    Future.microtask(() async {
      try {
        await DatabaseService.ensureUserSignedIn();
        _irrigationSub ??= _dbService.getDataStream().listen(
          _handleIrrigationEvent,
          onError: (_) {},
        );
      } catch (_) {}
    });
  }

  void _handleIrrigationEvent(DatabaseEvent event) {
    final snapshot = event.snapshot;
    final data = snapshot.value;
    final wasConnected = deviceConnected;
    deviceConnected = data != null && data is Map;
    if (deviceConnected != wasConnected) {
      notifyListeners();
    }
    if (data == null || data is! Map) return;

    final values = Map<dynamic, dynamic>.from(data);
    DateTime? latestTs;
    int? latestStatus;
    int? fallbackStatus;

    for (final entry in values.entries) {
      if (entry.value is! Map) continue;
      final item = Map<dynamic, dynamic>.from(entry.value as Map);
      final status = _extractPumpStatus(item);
      if (status == null) continue;

      final ts = _parseTimestamp(item);
      if (ts != null) {
        if (latestTs == null || ts.isAfter(latestTs)) {
          latestTs = ts;
          latestStatus = status;
        }
      } else {
        fallbackStatus = status;
      }
    }

    final nextStatus = latestStatus ?? fallbackStatus;
    if (nextStatus != null && nextStatus != pumpStatus) {
      pumpStatus = nextStatus;
      notifyListeners();
    }
  }

  DateTime? _parseTimestamp(Map<dynamic, dynamic> item) {
    final raw = item['timestamp'];
    if (raw is num) {
      final value = raw.toInt();
      // Support seconds-based values while migrating to milliseconds.
      final ms = value < 1000000000000 ? value * 1000 : value;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
    }

    final date = item['date'];
    final time = item['time'];
    if (date != null && time != null) {
      return DateTime.tryParse('${date.toString()} ${time.toString()}');
    }
    if (date != null) {
      return DateTime.tryParse(date.toString());
    }
    return null;
  }

  int? _extractPumpStatus(Map<dynamic, dynamic> item) {
    final candidates = [
      item['status'],
      item['pumpStatus'],
      item['irrigationStatus'],
      item['irrigation'],
      item['pump'],
    ];
    for (final raw in candidates) {
      final parsed = _normalizePumpStatus(raw);
      if (parsed != null) return parsed;
    }
    return null;
  }

  int? _normalizePumpStatus(dynamic raw) {
    if (raw == null) return null;
    if (raw is bool) return raw ? 1 : 0;
    if (raw is num) return raw == 0 ? 0 : 1;
    if (raw is String) {
      final value = raw.trim().toUpperCase();
      if (value == 'ON' || value == '1' || value == 'TRUE') return 1;
      if (value == 'OFF' || value == '0' || value == 'FALSE') return 0;
    }
    return null;
  }

  void _queueSend() {
    if (!_sendingEnabled) return;
    if (_sendQueued) return;
    _sendQueued = true;
    Future.microtask(() {
      _sendQueued = false;
      sendDataToESP();
    });
  }

  bool _recomputeDerivedFields() {
    if (startDate == null || method == null) return false;

    final now = DateTime.now();
    final computedDays = now.difference(startDate!).inDays;
    final computedStage = Growthstage.getGrowthStage(method, startDate!);

    bool changed = false;
    if (days != computedDays) {
      days = computedDays;
      changed = true;
    }
    if (growthStage != computedStage) {
      growthStage = computedStage;
      changed = true;
    }
    return changed;
  }

  void setMethod(String value) {
    if (method == value) return;
    method = value;
    _recomputeDerivedFields();
    notifyListeners();
    _persistFieldData();
    _queueSend();
  }

  void setLocation(String value) {
    if (location == value) return;
    location = value;
    notifyListeners();
    _persistFieldData();
  }

  void setStartDate(DateTime value) {
    if (startDate == value) return;
    startDate = value;
    _recomputeDerivedFields();
    notifyListeners();
    _persistFieldData();
    _queueSend();
  }

  void setDays(int value) {
    if (days == value) return;
    days = value;
    notifyListeners();
    _queueSend();
  }

  void setGrowthStage(String value) {
    if (growthStage == value) return;
    growthStage = value;
    notifyListeners();
    _queueSend();
  }

  void setPrecipitation(double rain) {
    if (rainfallMM != null && (rainfallMM! - rain).abs() < 0.01) return;
    rainfallMM = rain;
    notifyListeners();
    _queueSend();
  }

  void setCoordinates(double lat, double lon) {
    if (latitude == lat && longitude == lon) return;
    latitude = lat;
    longitude = lon;
    notifyListeners();
    _persistFieldData();
  }

  /// Enable sending to the ESP after the user submits the form.
  void enableSending() {
    if (_sendingEnabled) return;
    _sendingEnabled = true;
    _persistFieldData();
  }

  void setUserControl(int value, {bool override = true}) {
    userControl = value;
    pumpStatus = value == -1 ? pumpStatus : value;
    manualOverride = override && value != -1;
    notifyListeners();
  }

  Future<void> sendDataToESP({int? overrideUserControl}) async {
    if (!_sendingEnabled) {
      return;
    }
    if (method == null || startDate == null || days == null || growthStage == null) {
      // Don't attempt to send until the essentials are available.
      return;
    }

    await DatabaseService.ensureUserSignedIn();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      irrigationStatus = "No UID available";
      notifyListeners();
      return;
    }

    final url = Uri.parse('http://$_espHost/update_mobile_data');

    final controlFlag = overrideUserControl ?? (manualOverride ? userControl : -1);

    final payload = {
      "uid": uid,
      "planting_method": method,
      "days": days,
      "growth_stage": growthStage,
      "rainfall_mm": rainfallMM ?? 0,
      "user_control": controlFlag,
    };
    final body = jsonEncode(payload);

    if (_lastSentBody == body) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: body,
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        irrigationStatus = result['status'] ?? "Updated successfully";
        _lastSentBody = body;
      } else {
        irrigationStatus = "Error: ${response.statusCode}";
      }
    } on TimeoutException {
      irrigationStatus = "Connection timed out";
    } catch (e) {
      irrigationStatus = "Connection failed: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> manualControl() async {
    if (_manualInFlight) return;

    // If user tries manual before an explicit enable, allow it and start sending.
    if (!_sendingEnabled) {
      _sendingEnabled = true;
    }
    pumpStatus = pumpStatus == 0 ? 1 : 0;
    userControl = pumpStatus;
    manualOverride = true;
    notifyListeners();

    await _sendManualOverride(userControl);
  }

  void resetToAuto() {
    userControl = -1;
    manualOverride = false;
    notifyListeners();
  }

  Future<void> _sendManualOverride(int value) async {
    await DatabaseService.ensureUserSignedIn();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      irrigationStatus = "No UID available";
      notifyListeners();
      return;
    }

    final url = Uri.parse('http://$_espHost/update_mobile_data');
    final payload = {
      "uid": uid,
      "planting_method": method ?? "",
      "days": days ?? 0,
      "growth_stage": growthStage ?? "",
      "rainfall_mm": rainfallMM ?? 0,
      "user_control": value,
    };
    final body = jsonEncode(payload);

    _manualInFlight = true;
    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: body,
          )
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        irrigationStatus = result['status'] ?? "Updated successfully";
      } else {
        irrigationStatus = "Error: ${response.statusCode}";
      }
    } on TimeoutException {
      irrigationStatus = "Connection timed out";
    } catch (e) {
      irrigationStatus = "Connection failed: $e";
    } finally {
      _manualInFlight = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _irrigationSub?.cancel();
    super.dispose();
  }

  Future<void> _hydrateFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      method = prefs.getString(_methodKey);
      location = prefs.getString(_locationKey);

      final savedDate = prefs.getString(_startDateKey);
      if (savedDate != null) {
        startDate = DateTime.tryParse(savedDate);
      }

      latitude = prefs.getDouble(_latKey);
      longitude = prefs.getDouble(_lonKey);
      _sendingEnabled = prefs.getBool(_setupCompleteKey) ?? false;

      _recomputeDerivedFields();
    } catch (_) {
      // Ignore storage issues to avoid blocking app startup.
    } finally {
      _hydrated = true;
      notifyListeners();
    }
  }

  void _persistFieldData() {
    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();

      if (method != null) {
        await prefs.setString(_methodKey, method!);
      } else {
        await prefs.remove(_methodKey);
      }

      if (location != null && location!.trim().isNotEmpty) {
        await prefs.setString(_locationKey, location!.trim());
      } else {
        await prefs.remove(_locationKey);
      }

      if (startDate != null) {
        await prefs.setString(
            _startDateKey, startDate!.toIso8601String());
      } else {
        await prefs.remove(_startDateKey);
      }

      if (latitude != null) {
        await prefs.setDouble(_latKey, latitude!);
      } else {
        await prefs.remove(_latKey);
      }

      if (longitude != null) {
        await prefs.setDouble(_lonKey, longitude!);
      } else {
        await prefs.remove(_lonKey);
      }

      await prefs.setBool(_setupCompleteKey, hasSavedFieldData);
    });
  }

  Future<void> resetFieldData() async {
    method = null;
    location = null;
    latitude = null;
    longitude = null;
    startDate = null;
    days = null;
    growthStage = null;
    rainfallMM = null;
    userControl = -1;
    manualOverride = false;
    _sendingEnabled = false;
    _lastSentBody = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_methodKey);
    await prefs.remove(_locationKey);
    await prefs.remove(_startDateKey);
    await prefs.remove(_latKey);
    await prefs.remove(_lonKey);
    await prefs.setBool(_setupCompleteKey, false);
  }
}
