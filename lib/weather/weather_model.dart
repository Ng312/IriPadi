class Weather {
  final double temperature; // in °C
  final String condition; // e.g., "Sunny"
  final double precipitationQuantity; // in mm
  final double precipitationProbability; // in %

  Weather({
    required this.temperature,
    required this.condition,
    required this.precipitationQuantity,
    required this.precipitationProbability,
  });

  /// ✅ Parse Google Weather API JSON
  factory Weather.fromJson(Map<String, dynamic> json) {
    final weatherCond = json['weatherCondition'] ?? {};
    final precipitation = json['precipitation'] ?? {};

    return Weather(
      temperature: (json['temperature']?['degrees'] ?? 0).toDouble(),
      condition: weatherCond['description']?['text'] ?? 'Unknown',
      precipitationQuantity:
          (precipitation['qpf']?['quantity'] ?? 0).toDouble(),
      precipitationProbability:
          (precipitation['probability']?['percent'] ?? 0).toDouble(),
    );
  }
}
