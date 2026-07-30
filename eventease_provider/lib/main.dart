import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/route_config.dart';

import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/language_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/review_provider.dart';
import 'providers/service_provider.dart';
import 'providers/theme_provider.dart';

import 'core/storage/storage_helper.dart';

import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageHelper.init();

  runApp(
    const EventEaseProviderApp(),
  );
}

class EventEaseProviderApp
    extends StatelessWidget {
  const EventEaseProviderApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ServiceProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => BookingProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => PaymentProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ReviewProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              NotificationProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              LanguageProvider(),
        ),
      ],
      child:
          Consumer2<
            ThemeProvider,
            LanguageProvider
          >(
        builder: (
          context,
          themeProvider,
          languageProvider,
          child,
        ) {
          return MaterialApp(
            debugShowCheckedModeBanner:
                false,

            title:
                'EventEase Provider',

            themeMode:
                themeProvider.themeMode,

            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed:
                  Colors.blue,
              brightness:
                  Brightness.light,
            ),

            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed:
                  Colors.blue,
              brightness:
                  Brightness.dark,
            ),

            locale:
                languageProvider.locale,

            supportedLocales:
                LanguageProvider
                    .supportedLocales,

            localizationsDelegates: const [
              GlobalMaterialLocalizations
                  .delegate,
              GlobalWidgetsLocalizations
                  .delegate,
              GlobalCupertinoLocalizations
                  .delegate,
            ],

            initialRoute:
                RouteConfig.splash,

            onGenerateRoute:
                RouteConfig
                    .onGenerateRoute,

            home:
                const SplashScreen(),
          );
        },
      ),
    );
  }
}