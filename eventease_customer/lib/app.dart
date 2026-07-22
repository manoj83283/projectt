import 'package:flutter/material.dart';

import 'utils/app_constants.dart';
import 'utils/app_styles.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';

class EventEaseApp extends StatelessWidget {
  const EventEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,

      debugShowCheckedModeBanner: false,

      theme: AppStyles.lightTheme,

      darkTheme: ThemeData.dark(),

      themeMode: ThemeMode.system,

      // Initial Screen
      home: const SplashScreen(),

      // Named Routes
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },

      // Global Builder
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler:
                const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}