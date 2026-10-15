import '../constants/app_constants.dart';

abstract class Validators {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  static final RegExp _hexColorRegex = RegExp(
    r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$',
  );

  static final RegExp _timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');

  /// Validates task/project/item titles.
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.trim().length > AppConstants.maxTitleLength) {
      return 'Title cannot exceed ${AppConstants.maxTitleLength} characters';
    }
    return null;
  }

  /// Validates email format.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates URL format.
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    if (!isValidUrl(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Validates hex color code format (#RGB, #RRGGBB, #AARRGGBB).
  static String? validateHexColor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Color is required';
    }
    if (!isValidHexColor(value)) {
      return 'Please enter a valid hex color';
    }
    return null;
  }

  /// Validates 24-hour time string in HH:mm format.
  static String? validateTimeString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Time is required';
    }
    if (!_timeRegex.hasMatch(value.trim())) {
      return 'Please enter a valid time (HH:mm)';
    }
    return null;
  }

  /// Validates positive numeric input.
  static String? validatePositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Number is required';
    }
    final number = num.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number <= 0) {
      return 'Number must be greater than zero';
    }
    return null;
  }

  /// Checks if URL is valid with http or https scheme.
  static bool isValidUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.hasAuthority &&
        uri.host.isNotEmpty;
  }

  /// Checks if string is a valid email address.
  static bool isValidEmail(String email) {
    if (email.trim().isEmpty) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  /// Checks if string is a valid hex color code.
  static bool isValidHexColor(String color) {
    return _hexColorRegex.hasMatch(color.trim());
  }
}
