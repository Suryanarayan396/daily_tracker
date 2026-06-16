import 'package:flutter/material.dart';
import '../extensions/context_extension.dart';
import '../constants/app_sizes.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final double defaultWidth = context.screenWidth * 0.85;
    final double defaultHeight = context.screenHeight * 0.06;

    return SizedBox(
      width: width ?? defaultWidth,
      height: height ?? defaultHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? context.colorScheme.primary,
          foregroundColor: textColor ?? context.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.br8),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: context.screenHeight * 0.03,
                height: context.screenHeight * 0.03,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? context.colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                text,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
      ),
    );
  }
}
