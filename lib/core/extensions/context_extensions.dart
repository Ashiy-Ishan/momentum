import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  bool get isDesktop => screenWidth >= AppConstants.desktopBreakpoint;
  bool get isTablet =>
      screenWidth >= AppConstants.tabletBreakpoint &&
      screenWidth < AppConstants.desktopBreakpoint;
  bool get isMobile => screenWidth < AppConstants.tabletBreakpoint;

  void showSnackBar(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(this);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isError ? colorScheme.onError : colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: isError
            ? colorScheme.error
            : colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
