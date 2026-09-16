import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/weather/weather_model.dart';
import 'package:flutter_application_1/weather/forecast_model.dart';
import 'package:flutter_application_1/widgets/form_data_provider.dart';
import 'package:provider/provider.dart';
import 'weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService(
    googleApiKey: 'AIzaSyD9r8tIYNQhG-ZwkV39ujPSVuadwWFs9dU',
  );
  Weather? _weather;
  List<Forecast>? _forecast;
  String? _lastLocationName;

  Weather? get weather => _weather;

  DateTime? _lastUpdated;
  DateTime? get lastUpdated => _lastUpdated;

  Future<Map<String, dynamic>?> resolveLocation(String query) {
    return _weatherService.geocodeLocation(query);
  }

  String buildSummary(AppLocalizations l10n) {
    if (_weather == null || _forecast == null) return '';
    return _buildSummary(_weather!, _forecast!, l10n, _lastLocationName);
  }

  String _buildSummary(Weather weather, List<Forecast> forecast,
      AppLocalizations l10n, String? location) {
    final nextForecasts = forecast.take(6).toList();
    if (weather.condition.toLowerCase().contains("rain") ||
        weather.condition.toLowerCase().contains("drizzle") ||
        weather.condition.toLowerCase().contains("shower")) {
      return l10n.weatherRaining(location);
    }

    final rainComing = nextForecasts.any((f) => (f.rainProbability) > 50);
    if (rainComing) {
      final firstRain =
          nextForecasts.firstWhere((f) => (f.rainProbability) > 50);
      final hour = firstRain.dateTime.hour.toString().padLeft(2, '0');
      final probability = firstRain.rainProbability.round();
      return l10n.weatherRainChance(probability, hour);
    }

    return l10n.weatherNoRainExpected(weather.condition);
  }

  Future<void> fetchWeather(
      BuildContext context, double lat, double lon, String? location) async {
    try {
      final formData =
          Provider.of<FormDataProvider>(context, listen: false);
      // ignore: avoid_print
      print('[WeatherProvider] fetchWeather lat=$lat lon=$lon location="$location"');
      _weatherService.stopAutoUpdates();
      await _weatherService.startAutoUpdates(
        lat,
        lon,
        onUpdate: (weather, forecast) {
          formData.setPrecipitation(weather.precipitationQuantity);

          _forecast = forecast;
          _lastLocationName = location;
          _weather = weather;
          _lastUpdated = DateTime.now(); // 👈 mark update time
          notifyListeners();

        },
      );
    } catch (e) {
      print("Error fetching weather: $e");
    }
  }

}
