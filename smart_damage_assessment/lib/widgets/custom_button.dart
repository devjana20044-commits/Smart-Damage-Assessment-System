import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Custom button widget with loading state support
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !isLoading && !isDisabled && onPressed != null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? (backgroundColor ?? theme.primaryColor)
              : theme.disabledColor,
          foregroundColor: textColor ?? Colors.white,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          elevation: isEnabled ? 2 : 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: textColor ?? Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Outlined version of custom button
class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.borderColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !isLoading && !isDisabled && onPressed != null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 48,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isEnabled
                ? (borderColor ?? theme.primaryColor)
                : theme.disabledColor,
            width: 1.5,
          ),
          foregroundColor: isEnabled
              ? (textColor ?? theme.primaryColor)
              : theme.disabledColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isEnabled
                      ? (textColor ?? theme.primaryColor)
                      : theme.disabledColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}