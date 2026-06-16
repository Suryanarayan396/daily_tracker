import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  // Theme extensions
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  // Responsive design using MediaQuery as per project standard
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  // Relative width and height multipliers
  double widthPct(double percent) => screenWidth * percent;
  double heightPct(double percent) => screenHeight * percent;

  // Check orientation
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
}
