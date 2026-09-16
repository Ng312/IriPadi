class Forecast {
  final DateTime dateTime;
  final double temperature;
  final int rainProbability;

  Forecast({
    required this.dateTime,
    required this.temperature,
    required this.rainProbability,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      dateTime: DateTime.parse(json['date']),
      temperature: (json['temperature']?['degrees'] ?? 0).toDouble(),
      rainProbability:
          (json['precipitation']?['probability']?['percent'] ?? 0).toInt(),
    );
  }
}
