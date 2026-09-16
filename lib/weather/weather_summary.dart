import 'forecast_model.dart';
import 'weather_model.dart';

String buildWeatherSummary(
  Weather weather,
  List<Forecast> forecast, {
  String? location,
}) {
  final target = location ?? 'your area';
  final lowerCondition = weather.condition.toLowerCase();
  if (lowerCondition.contains('rain') ||
      lowerCondition.contains('drizzle') ||
      lowerCondition.contains('shower')) {
    return "It’s currently raining in $target.";
  }

  final nextForecasts = forecast.take(6).toList();
  final rainComing = nextForecasts.any((f) => f.rainProbability > 50);
  if (rainComing) {
    final firstRain =
        nextForecasts.firstWhere((f) => f.rainProbability > 50);
    final hour = firstRain.dateTime.hour.toString().padLeft(2, '0');
    return "No rain right now, but there’s a ${firstRain.rainProbability}% chance around $hour:00.";
  }

  return "No rain expected in the next few hours. It looks ${weather.condition.toLowerCase()}.";
}
