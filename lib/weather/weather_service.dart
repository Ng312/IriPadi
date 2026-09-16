import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../weather/weather_model.dart';
import '../weather/forecast_model.dart';
import 'package:geolocator/geolocator.dart';

class WeatherService {
  final String googleApiKey;
  Timer? _timer;

  WeatherService({
    required this.googleApiKey,
  });

  Future<Map<String, dynamic>?> geocodeLocation(String query) async {
    Future<Map<String, dynamic>?> attempt(String q) async {
      // Debug: show query being attempted
      // Note: do not log API key
      // ignore: avoid_print
      print('[Geocode] Attempting: "$q"');
      final encoded = Uri.encodeComponent(q);
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=$encoded&key=$googleApiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        // ignore: avoid_print
        print('[Geocode] HTTP ${response.statusCode} for "$q"');
        return null;
      }
      final data = json.decode(response.body);
      if (data['status'] != 'OK') {
        // ignore: avoid_print
        print('[Geocode] API status ${data['status']} for "$q"');
        return null;
      }
      final results = data['results'] as List<dynamic>;
      if (results.isEmpty) return null;

      final first = results.first;
      final location = first['geometry']?['location'];
      if (location == null) return null;

      final double lat = (location['lat'] as num).toDouble();
      final double lon = (location['lng'] as num).toDouble();
      final formattedName =
          (first['formatted_address'] as String?)?.split(',').take(2).join(',').trim() ??
              q;
      // ignore: avoid_print
      print(
          '[Geocode] Found $formattedName @ ${location['lat']}, ${location['lng']}');

      return {
        'lat': lat,
        'lon': lon,
        'name': formattedName,
      };
    }

    try {
      // First try the full query
      final firstTry = await attempt(query);
      if (firstTry != null) return firstTry;

      // If no direct match, progressively broaden the query (drop last term)
      final parts = query.split(RegExp(r'[,+]')).map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
      while (parts.length > 1) {
        parts.removeLast();
        final broadened = parts.join(', ');
        final fallback = await attempt(broadened);
        if (fallback != null) return fallback;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw Exception('Location permissions are permanently denied.');
    }
  }

  Future<void> _ensureLocationServiceEnabled() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) return;

    await Geolocator.openLocationSettings();
    for (var attempt = 0; attempt < 10; attempt += 1) {
      await Future.delayed(const Duration(seconds: 1));
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) return;
    }
    throw Exception(
        'Location services are disabled. Please enable location and try again.');
  }

  Future<Position> _getCurrentPosition() async {
    await _ensureLocationPermission();
    await _ensureLocationServiceEnabled();
    // geolocator 9.x uses the legacy signature without LocationSettings
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      forceAndroidLocationManager: true, // avoid Play Services dependency
    );
  }

  Future<String> _getCityName(double lat, double lon) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$googleApiKey';
    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      List<String> locationName;
      String city = '';
      bool hasPlusCode = false;
      print("Geocoding response : $data");

      if (data['status'] == 'OK') {
        final results = data['results'];
        if (results.isNotEmpty) {
          for (var component in results[0]['address_components']) {
            if ((component['types'] as List).contains('plus_code')) {
              hasPlusCode = true;
            }
            if (hasPlusCode) {
              if ((component['types'] as List).contains('locality')) {
                city = component['long_name'];
                break;
              }
            } else {
              locationName = (results[0]['formatted_address']).split(',') ?? [];
              city = locationName.sublist(0, 2).join(',').trim();
            }
          }
        }
      }
      return city;
    } catch (e) {
      print("error : $e");
      return 'Unknown location';
    }
  }

  Future<Map<String, dynamic>> getCurrentLocationData(
      {String locationName = ''}) async {
    final position = await _getCurrentPosition();
    final String cityName;
    if (locationName != '') {
      cityName = locationName;
    } else {
      cityName = await _getCityName(position.latitude, position.longitude);
    }

    return {
      'lat': position.latitude,
      'lon': position.longitude,
      'name': cityName,
    };
  }

  /// Use Google Weather API to get current conditions
  Future<Weather> getWeather(double lat, double lon) async {
    // ignore: avoid_print
    print('[Weather] Fetching current conditions for $lat, $lon');
    final url = 'https://weather.googleapis.com/v1/currentConditions:lookup'
        '?key=$googleApiKey'
        '&location.latitude=$lat'
        '&location.longitude=$lon';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final weather = Weather.fromJson(data);
      print('Temp: ${weather.temperature}°C');
      print('Condition: ${weather.condition}');
      print('Precipitation: ${weather.precipitationQuantity} mm');
      print('Chance: ${weather.precipitationProbability}%');
      return Weather.fromJson(data);
    } else {
      // ignore: avoid_print
      print('[Weather] Failed with ${response.statusCode}: ${response.body}');
      throw Exception('Failed to load weather: ${response.statusCode}');
    }
  }

  Future<List<Forecast>> getForecast(double lat, double lon) async {
    // ignore: avoid_print
    print('[Weather] Fetching forecast for $lat, $lon');
    final url = 'https://weather.googleapis.com/v1/forecast/hours:lookup'
        '?key=$googleApiKey'
        '&location.latitude=$lat'
        '&location.longitude=$lon'
        '&hours=6'; // or however many hours you want

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> list = [];
      if (data['hourlyForecasts'] != null) {
        list = data['hourlyForecasts'] as List<dynamic>;
      } else if (data['dailyForecasts'] != null) {
        list = data['dailyForecasts'] as List<dynamic>;
      }
      return list.map((e) => Forecast.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load forecast: ${response.statusCode}');
    }
  }

  Future<void> startAutoUpdates(
    double lat,
    double lon, {
    Function(Weather weather, List<Forecast> forecast)? onUpdate,
  }) async {
    // Cancel previous timer
    _timer?.cancel();
    _timer = null;

    // Fetch immediately
    final weather = await getWeather(lat, lon);
    final forecast = await getForecast(lat, lon);
    if (onUpdate != null) onUpdate(weather, forecast);

    // Repeat every 10 minutes
    _timer = Timer.periodic(const Duration(minutes: 10), (_) async {
      try {
        final w = await getWeather(lat, lon);
        final f = await getForecast(lat, lon);
        if (onUpdate != null) onUpdate(w, f);
        print('Weather auto-updated');
      } catch (e) {
        print('Auto update failed: $e');
      }
    });
  }

  void stopAutoUpdates() {
    _timer?.cancel();
    _timer = null;
  }
}
