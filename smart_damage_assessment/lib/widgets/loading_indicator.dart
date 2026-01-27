import 'package:flutter/material.dart';

/// Loading indicator widget with customizable message
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final double strokeWidth;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 40,
    this.color,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? theme.primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;
  final double opacity;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: (backgroundColor ?? Colors.black).withOpacity(opacity),
            child: LoadingIndicator(
              message: message ?? 'Loading...',
              size: 50,
            ),
          ),
      ],
    );
  }
}

/// Skeleton loading for content
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: Color.lerp(
              theme.colorScheme.surfaceVariant.withOpacity(0.3),
              theme.colorScheme.surfaceVariant.withOpacity(0.1),
              _animation.value,
            ),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

/// List skeleton for loading states
class ListSkeletonLoader extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const ListSkeletonLoader({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SkeletonLoader(
                  width: 60,
                  height: itemHeight,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(
                        width: double.infinity,
                        height: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      SkeletonLoader(
                        width: 200,
                        height: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      SkeletonLoader(
                        width: 150,
                        height: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}