import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avtoassist/providers/auth_provider.dart';
import 'package:avtoassist/providers/order_provider.dart';
import 'package:avtoassist/screens/splash_screen.dart';
import 'package:avtoassist/utils/app_theme.dart';

void main() {
  runApp(const AvtoAssistApp());
}

class AvtoAssistApp extends StatelessWidget {
  const AvtoAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'AvtoAssist',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
