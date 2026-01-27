import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    if (success && mounted) {
      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
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

  String? _validatePasswordConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                      Icons.person_add,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Create Account',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Join us to start reporting damage',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Name field
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

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
                    hintText: 'Create a password',
                    showValidation: true,
                  ),

                  const SizedBox(height: 16),

                  // Confirm password field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'Confirm your password',
                    isPassword: true,
                    validator: _validatePasswordConfirmation,
                  ),

                  const SizedBox(height: 32),

                  // Register button
                  CustomButton(
                    text: 'Create Account',
                    onPressed: authProvider.isLoading ? null : _register,
                    isLoading: authProvider.isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Sign In',
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
                      message: 'Creating account...',
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