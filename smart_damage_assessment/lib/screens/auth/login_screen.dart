import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    print('🔐 LOGIN SCREEN - Login button pressed');
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    print('🔐 LOGIN SCREEN - Calling authProvider.login()');
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    print('🔐 LOGIN SCREEN - authProvider.login() returned: $success');
    print('🔐 LOGIN SCREEN - mounted: $mounted');

    if (success && mounted) {
      print('✅ LOGIN SCREEN - Navigating to HomeScreen');
      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      print('❌ LOGIN SCREEN - Navigation not triggered. success=$success, mounted=$mounted');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    // Show error message if any
    if (authProvider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(authProvider.errorMessage!);
        authProvider.clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            tooltip: 'الإعدادات',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Welcome Back',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Sign in to continue reporting damage',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Email field
                  EmailTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  PasswordTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                  ),

                  const SizedBox(height: 32),

                  // Login button
                  CustomButton(
                    text: 'Sign In',
                    onPressed: authProvider.isLoading ? null : _login,
                    isLoading: authProvider.isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Sign Up',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Loading overlay
                  if (authProvider.isLoading)
                    const LoadingOverlay(
                      isLoading: true,
                      child: SizedBox.shrink(),
                      message: 'Signing in...',
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}