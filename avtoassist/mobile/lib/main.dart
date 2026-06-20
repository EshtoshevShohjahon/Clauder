import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:avtoassist/providers/auth_provider.dart';
import 'package:avtoassist/providers/order_provider.dart';
import 'package:avtoassist/providers/theme_provider.dart';
import 'package:avtoassist/providers/places_provider.dart';
import 'package:avtoassist/providers/locale_provider.dart';
import 'package:avtoassist/screens/splash_screen.dart';
import 'package:avtoassist/utils/app_theme.dart';

void main() {
  runApp(const AvtoHelpApp());
}

class AvtoHelpApp extends StatelessWidget {
  const AvtoHelpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => PlacesProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return MaterialApp(
            title: 'AvtoHelp',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Tillar (4 ta)
            locale: localeProvider.locale,
            supportedLocales: LocaleProvider.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // uz_Cyrl uchun fallback: uz material lokalizatsiyasi
            localeResolutionCallback: (locale, supported) {
              if (locale == null) return const Locale('uz');
              for (final l in supported) {
                if (l.languageCode == locale.languageCode) return l;
              }
              return const Locale('uz');
            },

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
