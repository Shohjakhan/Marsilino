import 'package:flutter/material.dart';

/// App-wide design tokens for the Restaurant app.
/// Contains colors, radii, shadows, typography, and helper styles.

// =============================================================================
// COLORS
// =============================================================================

/// Primary brand color
const Color kPrimary = Color(0xFF2090F9);

/// Bold/darker variant of primary color
const Color kPrimaryBold = Color(0xFF1566B2);

/// App background color
const Color kBackground = Color(0xFFD9EDFF);

/// Card background color
const Color kCardBg = Color(0xFFFFFFFF);

/// Primary text color
const Color kTextPrimary = Color(0xFF0D1A2B);

/// Secondary/muted text color
const Color kTextSecondary = Color(0xFF6B7C93);

// =============================================================================
// RADII
// =============================================================================

/// Border radius for cards
const double kCardRadius = 22.0;

/// Border radius for buttons
const double kButtonRadius = 30.0;

// =============================================================================
// SHADOWS
// =============================================================================

/// Standard card shadow
const BoxShadow kCardShadow = BoxShadow(
  color: Color(0x0F101828),
  offset: Offset(0, 8),
  blurRadius: 20,
);

// =============================================================================
// TYPOGRAPHY
// =============================================================================

/// Title text style (22sp)
const TextStyle kTitleStyle = TextStyle(
  fontFamily: '.SF Pro Text',
  fontSize: 22,
  fontWeight: FontWeight.w600,
  color: kTextPrimary,
);

/// Subtitle text style (16sp)
const TextStyle kSubtitleStyle = TextStyle(
  fontFamily: '.SF Pro Text',
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: kTextPrimary,
);

/// Body text style (14sp)
const TextStyle kBodyStyle = TextStyle(
  fontFamily: '.SF Pro Text',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: kTextPrimary,
);

// =============================================================================
// HELPER STYLES
// =============================================================================

/// Primary button style with rounded corners and primary color
final ButtonStyle kPrimaryButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: kPrimary,
  foregroundColor: kCardBg,
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(kButtonRadius),
  ),
  textStyle: const TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
  elevation: 0,
);

/// Standard input decoration for text fields
InputDecoration kInputDecoration({
  String? hintText,
  String? labelText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    labelText: labelText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: kCardBg,
    hintStyle: kBodyStyle.copyWith(color: kTextSecondary),
    labelStyle: kBodyStyle.copyWith(color: kTextSecondary),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kButtonRadius),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kButtonRadius),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kButtonRadius),
      borderSide: const BorderSide(color: kPrimary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kButtonRadius),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kButtonRadius),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );
}

/// Rounded card decoration with shadow
final BoxDecoration kRoundedCardDecoration = BoxDecoration(
  color: kCardBg,
  borderRadius: BorderRadius.circular(kCardRadius),
  boxShadow: const [kCardShadow],
);

/// Main Theme Data
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimary,
      surface: kBackground,
    ),
    scaffoldBackgroundColor: kBackground,
    fontFamily: '.SF Pro Text',
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: kPrimaryButtonStyle),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kCardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kButtonRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kButtonRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kButtonRadius),
        borderSide: const BorderSide(color: kPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kButtonRadius),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kButtonRadius),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      hintStyle: kBodyStyle.copyWith(color: kTextSecondary),
      labelStyle: kBodyStyle.copyWith(color: kTextSecondary),
    ),
  );
}
