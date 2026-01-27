import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: reportProvider),
      ],
      child: const SmartDamageAssessmentApp(),
    ),
  );
}

class SmartDamageAssessmentApp extends StatelessWidget {
  const SmartDamageAssessmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Damage Assessment',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
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
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Material(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong!',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please restart the app.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Restart the app
                      main();
                    },
                    child: const Text('Restart App'),
                  ),
                ],
              ),
            ),
          );
        };

        return child ?? const SizedBox.shrink();
      },
    );
  }
}
