import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/homepage.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Iri',
                      style: TextStyle(
                          fontSize: 74,
                          color: Color(0xFF148FD1),
                          fontFamily: 'RobotoCondensed'),
                    ),
                    Text(
                      'Padi',
                      style: TextStyle(
                          fontSize: 74,
                          color: Color(0xFF427662),
                          fontFamily: 'RobotoCondensed'),
                    ),
                  ],
                ),
                Text(
                  l10n.t('home.tagline.line1'),
                  style: TextStyle(
                      fontSize: 20, fontFamily: 'Outfit', height: 0.5,
                      ),
                ),
                Text(
                  l10n.t('home.tagline.line2'),
                  style: TextStyle(
                      fontSize: 20, fontFamily: 'Outfit', height: 2.0),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white.withValues(alpha: 0.67),
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                ),
                child: Text(
                  l10n.t('action.getStarted'),
                  style: const TextStyle(
                      fontSize: 25,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600),
                )),
          )
        ],
      ),
    );
  }
}
