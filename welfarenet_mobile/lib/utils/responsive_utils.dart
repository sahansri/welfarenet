import 'package:flutter/material.dart';

/// Responsive utilities for consistent sizing across different screen sizes
/// and font scale settings
class ResponsiveUtils {
  final BuildContext context;

  ResponsiveUtils(this.context);

  /// Get screen width
  double get screenWidth => MediaQuery.of(context).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(context).size.height;

  /// Get text scale factor (respects user's font size settings)
  double get textScaleFactor => MediaQuery.of(context).textScaleFactor;

  /// Check if screen is small (phone)
  bool get isSmallScreen => screenWidth < 600;

  /// Check if screen is medium (tablet in portrait)
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 840;

  /// Check if screen is large (tablet in landscape, desktop)
  bool get isLargeScreen => screenWidth >= 840;

  /// Responsive width based on percentage
  double widthPercent(double percent) {
    return screenWidth * (percent / 100);
  }

  /// Responsive height based on percentage
  double heightPercent(double percent) {
    return screenHeight * (percent / 100);
  }

  /// Responsive font size - automatically scales with screen size
  /// and respects user's font size settings
  double fontSize(double size) {
    // Base on a 375px width (iPhone SE size) as reference
    double scaleFactor = screenWidth / 375;

    // Clamp the scale factor to prevent extreme sizes
    scaleFactor = scaleFactor.clamp(0.8, 1.3);

    return size * scaleFactor;
  }

  /// Responsive spacing - scales with screen size
  double spacing(double size) {
    double scaleFactor = screenWidth / 375;
    scaleFactor = scaleFactor.clamp(0.8, 1.3);
    return size * scaleFactor;
  }

  /// Responsive icon size
  double iconSize(double size) {
    double scaleFactor = screenWidth / 375;
    scaleFactor = scaleFactor.clamp(0.8, 1.3);
    return size * scaleFactor;
  }

  /// Get responsive padding
  EdgeInsets get pagePadding {
    if (isLargeScreen) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    } else if (isMediumScreen) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  /// Get responsive card padding
  EdgeInsets get cardPadding {
    if (isLargeScreen) {
      return const EdgeInsets.all(20);
    } else if (isMediumScreen) {
      return const EdgeInsets.all(16);
    }
    return const EdgeInsets.all(12);
  }

  /// Get responsive border radius
  double get cardBorderRadius {
    if (isLargeScreen) return 20;
    if (isMediumScreen) return 16;
    return 12;
  }

  /// Get maximum content width for large screens
  double get maxContentWidth {
    if (isLargeScreen) return 800;
    return screenWidth;
  }
}

/// Extension to get ResponsiveUtils from BuildContext
extension ResponsiveExtension on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils(this);
}

/// Text styles with responsive sizing
class AppTextStyles {
  final BuildContext context;

  AppTextStyles(this.context);

  ResponsiveUtils get _r => ResponsiveUtils(context);

  TextStyle get headline1 => TextStyle(
    fontSize: _r.fontSize(32),
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  TextStyle get headline2 => TextStyle(
    fontSize: _r.fontSize(24),
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  TextStyle get headline3 => TextStyle(
    fontSize: _r.fontSize(20),
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  TextStyle get subtitle1 => TextStyle(
    fontSize: _r.fontSize(18),
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  TextStyle get subtitle2 => TextStyle(
    fontSize: _r.fontSize(16),
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  TextStyle get body1 => TextStyle(
    fontSize: _r.fontSize(16),
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  TextStyle get body2 => TextStyle(
    fontSize: _r.fontSize(14),
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  TextStyle get caption => TextStyle(
    fontSize: _r.fontSize(12),
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  TextStyle get button => TextStyle(
    fontSize: _r.fontSize(16),
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}

/// Extension to get AppTextStyles from BuildContext
extension TextStyleExtension on BuildContext {
  AppTextStyles get textStyles => AppTextStyles(this);
}
