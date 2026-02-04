import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/localization.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/report_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/dio_service.dart';
import 'services/report_service.dart';
import 'services/storage_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final storageService = await StorageService.getInstance();
  final dioService = await DioService.getInstance();

  // Initialize services with dependencies
  final authService = AuthService(dioService, storageService);
  final reportService = ReportService(dioService);

  // Initialize providers
  final authProvider = AuthProvider(authService, storageService, dioService);
  final reportProvider = ReportProvider(reportService);

  // Initialize auth provider
  await authProvider.initialize();

  // Initialize locale provider
  final localeProvider = LocaleProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: reportProvider),
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
            // Default Flutter localizations
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('ar'), // Arabic
          ],
          // RTL support
          builder: (context, child) {
            // Set text direction based on locale
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
            // Auth routes will be added when screens are created
            // '/login': (context) => const LoginScreen(),
            // '/register': (context) => const RegisterScreen(),
            // '/home': (context) => const HomeScreen(),
            // '/create-report': (context) => const CreateReportScreen(),
            // '/report-details': (context) => const ReportDetailsScreen(),
          },
          // Custom error widget for better error handling
          onGenerateTitle: (context) {
            return AppLocalizations.of(context)!.appTitle;
          },
        );
      },
    );
  }
}
