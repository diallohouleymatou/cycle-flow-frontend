import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool useGlassEffect;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor,
    this.useGlassEffect = false,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final Color effectiveColor = backgroundColor ?? theme.cardTheme.color ?? theme.colorScheme.surface;
    final Color borderColor = isDark 
        ? Colors.white.withOpacity(0.1) 
        : theme.dividerColor.withOpacity(0.5);

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: useGlassEffect ? 10 : 0,
          sigmaY: useGlassEffect ? 10 : 0,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: useGlassEffect 
                ? effectiveColor.withOpacity(0.7) 
                : effectiveColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: useGlassEffect 
                  ? Colors.white.withOpacity(0.2) 
                  : borderColor,
              width: 1,
            ),
            boxShadow: [
              if (!isDark) // No shadow in dark mode usually, or very subtle
                BoxShadow(
                  color: const Color(0xFF1C1C1E).withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap!();
        },
        child: content,
      );
    }

    return content;
  }
}