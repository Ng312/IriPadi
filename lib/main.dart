import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/pages/IrrigationLog.dart';
import 'package:flutter_application_1/pages/fieldInfo.dart';
import 'package:flutter_application_1/pages/loginPage.dart';
import 'package:flutter_application_1/pages/schedule.dart';
import 'package:flutter_application_1/weather/weather_provider.dart';
import 'package:flutter_application_1/widgets/form_data_provider.dart';
import 'package:flutter_application_1/widgets/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/dashboardPage.dart';
import 'package:flutter_application_1/pages/homePage.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'l10n/app_localizations.dart';
import 'pages/language_selection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => FormDataProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      fontFamily: 'Outfit',
      textTheme: ThemeData.light().textTheme.apply(
            fontFamily: 'Outfit',
            fontFamilyFallback: const [
              'Noto Sans SC',
              'PingFang SC',
              'Microsoft YaHei',
              'Heiti SC',
              'sans-serif',
            ],
          ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.withValues(alpha:0.7), 
        backgroundColor: const Color(0xFF006238),
      ),
    );

    return Consumer2<LocaleProvider, FormDataProvider>(
      builder: (context, localeProvider, formData, _) {
        Widget home;
        if (!localeProvider.isHydrated || !formData.isHydrated) {
          home = const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (!localeProvider.hasSelectedLocale) {
          home = const LanguageSelectionPage();
        } else if (formData.hasSavedFieldData) {
          home = const MainPage(
            key: ValueKey('main-dashboard'),
            initialIndex: 1,
          );
        } else {
          home = const MainPage(
            key: ValueKey('main-home'),
            initialIndex: 0,
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routes: {
            '/language': (context) => const LanguageSelectionPage(),
            '/home': (context) => const MainPage(initialIndex: 0),
            '/login': (context) => const LoginPage(),
            '/dashboard': (context) => const MainPage(initialIndex: 1),
          },
          home: home,
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  final int initialIndex;
  const MainPage({super.key, this.initialIndex = 0});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool get _showBottomBar => _selectedIndex != 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    print('Current UID: ${FirebaseAuth.instance.currentUser?.uid}');

  }

  @override
  void didUpdateWidget(covariant MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _selectedIndex = widget.initialIndex;
      });
    }
  }

  final List<Widget> _pages = [
    const HomePage(),
    const DashboardPage(),
    const IrrigationLogPage(),
    const SchedulePage(),
    const FieldInfoPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: _showBottomBar
            ? BottomNavigationBar(
                currentIndex: _selectedIndex - 1,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index + 1;
                  });
                },
                selectedLabelStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                iconSize: 25, // size of all icons
                type:
                    BottomNavigationBarType.fixed, // keep labels always visible
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home),
                    label: l10n.t('nav.dashboard'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.history),
                    label: l10n.t('nav.log'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.water_drop),
                    label: l10n.t('nav.schedule'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.info),
                    label: l10n.t('nav.info'),
                  ),
                ],
              )
            : null);
  }
}
