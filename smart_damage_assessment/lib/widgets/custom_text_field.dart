import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Custom text field widget with validation support
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final bool isPassword;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.isPassword = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText || widget.isPassword;
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: _controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      textCapitalization: widget.textCapitalization,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffixIcon,
        contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        filled: true,
        fillColor: widget.enabled ? theme.colorScheme.surface : theme.disabledColor.withOpacity(0.1),
        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
      ),
    );
  }
}

/// Email text field with built-in validation
class EmailTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  const EmailTextField({
    super.key,
    this.controller,
    this.labelText = 'Email',
    this.hintText = 'Enter your email',
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: const Icon(Icons.email_outlined),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }
}

/// Password text field with built-in validation
class PasswordTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool showValidation;

  const PasswordTextField({
    super.key,
    this.controller,
    this.labelText = 'Password',
    this.hintText = 'Enter your password',
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.showValidation = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      isPassword: true,
      textCapitalization: TextCapitalization.none,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: const Icon(Icons.lock_outlined),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (showValidation && value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
    );
  }
}