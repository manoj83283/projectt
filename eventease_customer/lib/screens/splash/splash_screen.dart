import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(
      AppConfig.splashDuration,
    );

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      RouteConfig.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          ThemeConfig.primaryColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                // ========================================
                // LOGO
                // ========================================

                Container(
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(
                          alpha: 0.15,
                        ),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset:
                            const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.event_available,
                    color:
                        ThemeConfig.primaryColor,
                    size: 70,
                  ),
                ),

                const SizedBox(height: 24),

                // ========================================
                // APP NAME
                // ========================================

                Text(
                  AppConfig.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 8),

                // ========================================
                // TAGLINE
                // ========================================

                Text(
                  AppConfig.appTagLine,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 50),

                // ========================================
                // LOADER
                // ========================================

                const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),

      // ========================================
      // VERSION
      // ========================================

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          bottom: 24,
        ),
        child: Text(
          'Version ${AppConfig.appVersion}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}