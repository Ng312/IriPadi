import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/weather/weather_service.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/widgets/form_data_provider.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _findLocation =
      WeatherService(googleApiKey: 'AIzaSyD9r8tIYNQhG-ZwkV39ujPSVuadwWFs9dU');
  String? selectedMethod; // store selected value
  final TextEditingController dateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  bool showSuggestion = false;
  bool isFetchingLocation = false;
  bool _isNavigating = false;
  String sessionToken = const Uuid().v4();
  double lat = 0;
  double lon = 0;

  var uuid = const Uuid();

  List<dynamic> listOfLocation = [];

  final _formKey = GlobalKey<FormState>();
  Future<void> _fetchLocation() async {
    final l10n = context.l10n;
    final formData = Provider.of<FormDataProvider>(context, listen: false);
    setState(() {
      isFetchingLocation = true; // start loading
    });

    try {
      final location = await _findLocation.getCurrentLocationData();
      if (!mounted) return;

      setState(() {
        formData.setLocation(location['name']);
        lat = location['lat'];
        lon = location['lon'];
        locationController.text = formData.location!;
        listOfLocation = [];
        showSuggestion = false; // hide suggestion list
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedToRetrieveLocation(e))),
      );
    } finally {
      if (mounted) {
        setState(() {
          isFetchingLocation = false; // stop loading
        });
      }
    }
  }

  @override
  void initState() {
    locationController.addListener(() {
      _onChange();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillFromFormData();
      _maybeSkipIfCompleted();
    });
    super.initState();
  }

  void _prefillFromFormData() {
    final formData = Provider.of<FormDataProvider>(context, listen: false);
    if (formData.location != null && formData.location!.trim().isNotEmpty) {
      locationController.text = formData.location!;
    }
    if (formData.startDate != null) {
      dateController.text =
          DateFormat('dd/MM/yyyy').format(formData.startDate!);
    }
    if (formData.method != null) {
      setState(() {
        selectedMethod = formData.method;
      });
    }
    if (formData.latitude != null) {
      lat = formData.latitude!;
    }
    if (formData.longitude != null) {
      lon = formData.longitude!;
    }
  }

  void _maybeSkipIfCompleted() {
    if (_isNavigating) return;
    final formData = Provider.of<FormDataProvider>(context, listen: false);
    if (formData.hasSavedFieldData) {
      _isNavigating = true;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  _onChange() {
    if (locationController.text.isEmpty) {
      setState(() {
        showSuggestion = false;
      });
    } else {
      setState(() {
        showSuggestion = true;
      });
    }
    placeSuggestion(locationController.text);
  }

  String _shortenLocation(String description) {
    final parts = description.split(',');
    if (parts.length > 1) {
      parts.removeLast(); // remove the country
      return parts.join(',').trim();
    }
    return description;
  }

  void placeSuggestion(String input) async {
    const String apiKey = 'AIzaSyD9r8tIYNQhG-ZwkV39ujPSVuadwWFs9dU';
    try {
      String basedUrl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$basedUrl?input=$input&components=country:MY&key=$apiKey&sessiontoken=$sessionToken';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      print(data);
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {
        setState(() {
          listOfLocation = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception('Fail to load');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  /// 📅 Date picker
  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now());
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
      final formData = Provider.of<FormDataProvider>(context, listen: false);
      formData.setStartDate(picked);
    }
  }

  Future<void> _getCoordinatesFromPlace(String placeId) async {
    const String apiKey =
        'AIzaSyD9r8tIYNQhG-ZwkV39ujPSVuadwWFs9dU'; // same key as above
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (response.statusCode == 200 &&
          data['status'] == 'OK' &&
          data['result'] != null) {
        final result = data['result'];
        final location = result['geometry']['location'];
        final latValue = location['lat'];
        final lonValue = location['lng'];
        final nameValue = result['name'] ?? result['formatted_address'];

        if (!mounted) return;
        setState(() {
          lat = latValue;
          lon = lonValue;
          locationController.text = _shortenLocation(nameValue);
          showSuggestion = false;
          listOfLocation = [];
        });
      } else {
        throw Exception('Failed to get place details');
      }
    } catch (e) {
      print('Error fetching place details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formData = Provider.of<FormDataProvider>(context);
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFFE2E3DA),
          body: SafeArea(
            child: Stack(
              clipBehavior: Clip.none, //allow overlay
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey, // <-- Form key here
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 50),
                                Text(
                                  l10n.t('form.paddyPrompt'),
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 30),

                            // 🌱 Planting Method
                            Text(
                              l10n.t('form.plantingMethod'),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField2<String>(
                              isExpanded: true,
                              value: selectedMethod ?? formData.method,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 250,
                              width: MediaQuery.of(context).size.width - 40,
                              elevation: 8, // mimic default DropdownButtonFormField shadow
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                              menuItemStyleData: const MenuItemStyleData(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                              hint: Text(l10n.t('form.selectMethod')),
                              items: [
                                DropdownMenuItem(
                                    value: 'Direct Seeding',
                                    child: Text(l10n.t('method.directSeeding'))),
                                DropdownMenuItem(
                                    value: 'Transplanting',
                                    child: Text(l10n.t('method.transplanting'))),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  selectedMethod = value;
                                  formData.setMethod(value);
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.t('form.validation.selectPlantingMethod');
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 30),

                            // 📅 Start Date
                            Text(
                              l10n.t('form.startDate'),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: dateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: const Icon(Icons.date_range),
                              ),
                              onTap: () {
                                selectDate();
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.t('form.validation.pickDate');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),

                            // 📍 Location
                            Text(
                              l10n.t('form.location'),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: locationController,
                              decoration: InputDecoration(
                                hintText: l10n.t('form.searchLocation'),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.t('form.validation.enterLocation');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),

                            // 🔹 Suggestion dropdown-style list
                            if (showSuggestion &&
                                locationController.text.isNotEmpty)
                              Container(
                                width: double.infinity,
                                constraints:
                                    const BoxConstraints(maxHeight: 200),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: listOfLocation.length,
                                  itemBuilder: (context, index) {
                                    final description = _shortenLocation(
                                        listOfLocation[index]['description']
                                            .toString());

                                    return InkWell(
                                      onTap: () async {
                                        FocusScope.of(context).unfocus();
                                        final placeId =
                                            listOfLocation[index]['place_id'];
                                        await _getCoordinatesFromPlace(placeId);
                                        setState(() {
                                          locationController.text = description;
                                          showSuggestion = false;
                                          formData.setLocation(locationController.text);
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 12.0),
                                        child: Text(description),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 20),

                            //Use Current Location Button
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed:
                                    isFetchingLocation ? null : _fetchLocation,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0xFFAC5B0E),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isFetchingLocation) ...[
                                      const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(l10n.t('action.fetchingLocation')),
                                    ] else ...[
                                      const Icon(Icons.location_searching),
                                      const SizedBox(width: 10),
                                      Text(l10n.t('action.useCurrentLocation')),
                                    ],
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🟢 Bottom button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(l10n.t('form.validation.fillRequired'))),
                          );
                          return;
                        }

                        final formData =
                            Provider.of<FormDataProvider>(context, listen: false);
                        final typedLocation = locationController.text.trim();

                        // If coords not set (manual typing), geocode the text to get lat/lon
                        if ((lat == 0 || lon == 0) && typedLocation.isNotEmpty) {
                          final resolved =
                              await _findLocation.geocodeLocation(typedLocation);
                          if (!context.mounted) return;
                          if (resolved == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(l10n.t('form.validation.locationNotFound'))),
                            );
                            return;
                          }
                          lat = (resolved['lat'] as num).toDouble();
                          lon = (resolved['lon'] as num).toDouble();
                          final resolvedName =
                              resolved['name'] as String? ?? typedLocation;
                          formData.setLocation(resolvedName);
                        } else if (typedLocation.isNotEmpty) {
                          formData.setLocation(typedLocation);
                        }

                        setState(() {
                          _isNavigating = true;
                        });
                        formData.setCoordinates(lat, lon);
                        formData.enableSending();
                        // Fire-and-forget to avoid blocking navigation on network call.
                        unawaited(formData.sendDataToESP());

                        Navigator.pushNamed(
                          context,
                          '/dashboard',
                          arguments: {
                            'lat': lat,
                            'lon': lon,
                          },
                        ).whenComplete(() {
                          if (mounted) {
                            setState(() {
                              _isNavigating = false;
                            });
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF006238),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 10),
                      ),
                      child: Text(
                        l10n.t('action.next'),
                        style: const TextStyle(
                            fontSize: 25,
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    if (_isNavigating)
      Positioned.fill(
        child: Container(
          color: Colors.black.withValues(alpha: 0.25),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
  ],
);
  }
}
