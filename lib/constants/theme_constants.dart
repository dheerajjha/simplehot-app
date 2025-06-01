// Input: None
// Output: Theme related constants for the app

import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryColor = Color(0xFF1DA1F2); // Twitter blue
  static const Color secondaryColor = Color(0xFF14171A);

  // Background colors
  static const Color backgroundColor = Color(0xFF000000);
  static const Color cardBackgroundColor = Color(0xFF1E1E1E);

  // Text colors
  static const Color primaryTextColor = Color(0xFFFFFFFF);
  static const Color secondaryTextColor = Color(0xFF8899A6);

  // Action colors
  static const Color gainColor = Color(0xFF00C853); // Green for price increases
  static const Color lossColor = Color(0xFFD50000); // Red for price decreases

  // UI element colors
  static const Color dividerColor = Color(0xFF38444D);
  static const Color iconColor = Color(0xFF8899A6);
  static const Color buttonColor = Color(0xFF1DA1F2);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryTextColor,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryTextColor,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: AppColors.primaryTextColor,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.secondaryTextColor,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

class AppSizes {
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;

  static const double smallRadius = 4.0;
  static const double mediumRadius = 8.0;
  static const double largeRadius = 16.0;

  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 32.0;
}
