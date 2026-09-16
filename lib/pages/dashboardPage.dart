import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/widgets/form_data_provider.dart';
import 'package:flutter_application_1/widgets/irrigationcontrol.dart';
import 'package:flutter_application_1/widgets/paddyfielddata.dart';
import 'package:flutter_application_1/widgets/test_waterlevelchart.dart';
import 'package:flutter_application_1/widgets/weather.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formData = Provider.of<FormDataProvider>(context);
    final args = ModalRoute.of(context)?.settings.arguments;

    double lat = formData.latitude ?? 0;
    double lon = formData.longitude ?? 0;

    if (args is Map<String, dynamic>) {
      final argLat = (args['lat'] as num?)?.toDouble();
      final argLon = (args['lon'] as num?)?.toDouble();
      if (argLat != null) {
        lat = argLat;
      }
      if (argLon != null) {
        lon = argLon;
      }

      if ((argLat != null && formData.latitude != argLat) ||
          (argLon != null && formData.longitude != argLon)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          formData.setCoordinates(argLat ?? lat, argLon ?? lon);
        });
      }
    }

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      color: const Color(0xFFE2E3DA),
      child: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Outfit'),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  l10n.t('page.dashboard.title'),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                //Weather Widget
                WeatherWidget(lat: lat, lon: lon),

                //Paddy Field Data Widget
                const PaddyFieldDataWidget(),

              

                //Water Level Chart Widget
                //const WaterLevelChartWidget(),
                TestWaterlevelchart(),

                IrrigationControlWidget(),

                

                const SizedBox(height: 50),

                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
