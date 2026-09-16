import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/weather/weather_provider.dart';
import 'package:flutter_application_1/widgets/form_data_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WeatherWidget extends StatefulWidget {
  final double lat;
  final double lon;
  const WeatherWidget(
      {super.key,
      required this.lat,
      required this.lon});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  late double _lat;
  late double _lon;
  String? _lastLocation;
  bool _fetchPending = false;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _lat = widget.lat;
    _lon = widget.lon;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final formData = Provider.of<FormDataProvider>(context, listen: false);
      _lastLocation = formData.location;
      _triggerFetch(formData.location);
    });
  }

  void _triggerFetch(String? location) {
    final l10n = context.l10n;
    if (_fetchPending) return;
    _fetchPending = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _fetchPending = false;
      final formData =
          Provider.of<FormDataProvider>(context, listen: false);
      final trimmed = location?.trim();
      final resolvedQuery =
          (trimmed != null && trimmed.isNotEmpty) ? trimmed : null;
      final hasLocationText = resolvedQuery != null;

      double targetLat = _lat;
      double targetLon = _lon;
      String? resolvedName = resolvedQuery;
      // ignore: avoid_print
      print('[WeatherWidget] Trigger fetch for "$resolvedName"');

      if (resolvedQuery != null) {
        final weatherProvider =
            Provider.of<WeatherProvider>(context, listen: false);
        final resolved = await weatherProvider.resolveLocation(resolvedQuery);
        if (!mounted) return;
        if (resolved != null) {
          targetLat = (resolved['lat'] as num).toDouble();
          targetLon = (resolved['lon'] as num).toDouble();
          final resolvedNameValue =
              resolved['name'] as String? ?? resolvedQuery;
          resolvedName = resolvedNameValue;
          // ignore: avoid_print
          print(
              '[WeatherWidget] Resolved to "$resolvedName" @ $targetLat, $targetLon');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && formData.location != resolvedNameValue) {
              formData.setLocation(resolvedNameValue);
            }
            // Persist resolved coordinates so future builds use the same lat/lon.
            formData.setCoordinates(targetLat, targetLon);
          });
        } else {
          // ignore: avoid_print
          print('[WeatherWidget] Geocode failed for "$trimmed"');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  l10n.t('form.validation.locationNotFoundDetailed')),
            ),
          );
          return;
        }
      }

      final hasCoords = targetLat != 0.0 || targetLon != 0.0;
      if (!hasLocationText && !hasCoords) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(l10n.t('weather.chooseLocation')),
          ),
        );
        return;
      }
      if (!hasLocationText) {
        // Sync stored coords when using existing coordinates without text.
        formData.setCoordinates(targetLat, targetLon);
      }

      if (!mounted) return;
      final weatherProvider =
          Provider.of<WeatherProvider>(context, listen: false);
      // ignore: avoid_print
      print('[WeatherWidget] Fetch weather with $targetLat, $targetLon, "$resolvedName"');

      final coordsChanged =
          (_lat - targetLat).abs() > 1e-6 || (_lon - targetLon).abs() > 1e-6;
      final alreadyHasWeather =
          Provider.of<WeatherProvider>(context, listen: false).weather != null;
      if (!coordsChanged &&
          resolvedName == _lastLocation &&
          alreadyHasWeather) {
        // ignore: avoid_print
        print('[WeatherWidget] Skipping fetch; same location/coords as last fetch.');
        return;
      }

      _lastLocation = resolvedName;
      _lat = targetLat;
      _lon = targetLon;
      try {
        await weatherProvider.fetchWeather(
            context, targetLat, targetLon, resolvedName);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.weatherFetchFailed(e)),
          ),
        );
      }
    });
  }

  String getWeatherAnimation(String? condition) {
    if (condition == null) return 'assets/clear.json';

    final lower = condition.toLowerCase();

    if (lower.contains('clear') || lower.contains('sunny')) {
      return 'assets/clear.json';
    } else if (lower.contains('cloudy')) {
      return 'assets/cloud.json';
    } else if (lower.contains('light_rain')) {
      return 'assets/drizzle.json';
    } else if (lower.contains('rain')) {
      return 'assets/rain.json';
    } else if (lower.contains('thunderstorm')) {
      return 'assets/thunderstorm.json';
    } else if (lower.contains('windy')) {
      return 'assets/windy.json';
    } else {
      return 'assets/clear.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final formattedDate = DateFormat('dd/MM/yyyy', localeTag).format(now);
    final formData = Provider.of<FormDataProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final weather = weatherProvider.weather;
    final currentLocation = formData.location;

    if (currentLocation != _lastLocation) {
      _lastLocation = currentLocation;
      _triggerFetch(currentLocation);
    }
    final newPrecip = weather?.precipitationQuantity ?? 0;

    // Update precipitation after the frame to avoid notifying listeners mid-build
    if (formData.rainfallMM != newPrecip) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formData.setPrecipitation(newPrecip);
      });
    }

    final summaryMessage = weatherProvider.buildSummary(l10n);

    final place = (formData.location ?? '')
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    final location = place.take(2).join(', ');
    if (weather == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF00623A),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "$location • $formattedDate",
                  softWrap: true,
                   overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Outfit',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20,top:30),
                child: Text(
                  '${weather.temperature.round()}°C  ',
                  style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Lottie.asset(
                  getWeatherAnimation(weather.condition),
                  width: 80,
                  height: 80,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right:20),
                child: Text(
                  l10n.weatherCondition(weather.condition),
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
          const Divider(
              color: Colors.white, thickness: 1, indent: 10, endIndent: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              summaryMessage,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          /*Text(
            'Last updated: ${weatherProvider.lastUpdated != null ? DateFormat('HH:mm:ss').format(weatherProvider.lastUpdated!) : 'Fetching...'}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),*/

        ],
      ),
    );
  }
}
