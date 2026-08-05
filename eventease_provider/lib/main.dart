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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageHelper.init();

  runApp(
    const EventEaseProviderApp(),
  );
}

class EventEaseProviderApp extends StatelessWidget {
  const EventEaseProviderApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),

        ChangeNotifierProvider<ServiceProvider>(
          create: (_) => ServiceProvider(),
        ),

        ChangeNotifierProvider<BookingProvider>(
          create: (_) => BookingProvider(),
        ),

        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(),
        ),

        ChangeNotifierProvider<PaymentProvider>(
          create: (_) => PaymentProvider(),
        ),

        ChangeNotifierProvider<ReviewProvider>(
          create: (_) => ReviewProvider(),
        ),

        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),

        ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(),
        ),

        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),

        ChangeNotifierProvider<LanguageProvider>(
          create: (_) => LanguageProvider(),
        ),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (
          context,
          themeProvider,
          languageProvider,
          child,
        ) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            title: 'EventEase Provider',

            themeMode: themeProvider.themeMode,

            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blue,
              brightness: Brightness.light,
            ),

            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blue,
              brightness: Brightness.dark,
            ),

            locale: languageProvider.locale,

            /// ✅ FIXED: no dependency on LanguageProvider.supportedLocales
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
              Locale('te'),
              Locale('ta'),
              Locale('kn'),
              Locale('ml'),
              Locale('mr'),
              Locale('bn'),
            ],

            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            /// ✅ RouteConfig must contain splash + onGenerateRoute
            initialRoute: RouteConfig.splash,

            onGenerateRoute: RouteConfig.onGenerateRoute,
          );
        },
      ),
    );
  }
}