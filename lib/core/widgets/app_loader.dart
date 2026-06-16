import 'package:flutter/material.dart';
import '../extensions/context_extension.dart';
import '../constants/app_strings.dart';

class AppLoader extends StatelessWidget {
  final String? message;

  const AppLoader({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(context.colorScheme.primary),
          ),
          if (message != null || AppStrings.loading.isNotEmpty) ...[
            SizedBox(height: context.screenHeight * 0.02),
            Text(
              message ?? AppStrings.loading,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
