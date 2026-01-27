import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Wait for a short time to show the splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // Check if user is already authenticated
    if (authProvider.isAuthenticated) {
      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // Navigate to login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt,
                size: 60,
                color: theme.primaryColor,
              ),
            ),

            const SizedBox(height: 32),

            // App title
            Text(
              'Smart Damage\nAssessment',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Tagline
            Text(
              'AI-Powered Damage Reporting',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w300,
              ),
            ),

            const SizedBox(height: 48),

            // Loading indicator
            const LoadingIndicator(
              size: 32,
              color: Colors.white,
            ),

            const SizedBox(height: 16),

            // Loading text
            Text(
              'Initializing...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}