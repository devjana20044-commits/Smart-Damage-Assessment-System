import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/localization.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/draft_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/report_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/report/create_report_screen.dart';

import 'services/auth_service.dart';
import 'services/dio_service.dart';
import 'services/draft_service.dart';
import 'services/error_logger_service.dart';
import 'services/report_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error logger FIRST
  final errorLogger = await ErrorLoggerService.getInstance();
  globalErrorLogger = errorLogger;

  // Catch all Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    errorLogger.logFlutterError(details);
  };

  // Catch errors outside Flutter framework (async, isolates)
  PlatformDispatcher.instance.onError = (error, stack) {
    errorLogger.logError(
      source: 'PlatformDispatcher',
      error: error,
      stackTrace: stack,
    );
    return true; // Handled
  };

  final storageService = await StorageService.getInstance();
  final dioService = await DioService.getInstance();

  final authService = AuthService(dioService, storageService);
  final reportService = ReportService(dioService);
  final draftService = DraftService();

  final authProvider = AuthProvider(authService, storageService, dioService);
  final reportProvider = ReportProvider(reportService);
  final draftProvider = DraftProvider(draftService);

  await authProvider.initialize();

  final localeProvider = LocaleProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: reportProvider),
        ChangeNotifierProvider.value(value: draftProvider),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: const SmartDamageAssessmentApp(),
    ),
  );
}

class SmartDamageAssessmentApp extends StatelessWidget {
  const SmartDamageAssessmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final locale = localeProvider.locale ?? const Locale('en');

        return MaterialApp(
          title: 'Smart Damage Assessment',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ar')],
          builder: (context, child) {
            final textDirection = locale.languageCode == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr;

            return Directionality(
              textDirection: textDirection,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const SplashScreen(),
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
            '/create-report': (context) => const CreateReportScreen(),
          },
          onGenerateTitle: (context) {
            return AppLocalizations.of(context)!.appTitle;
          },
        );
      },
    );
  }
}
