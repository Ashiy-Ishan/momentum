import '../utils/string_utils.dart';
import '../utils/validators.dart';

extension StringX on String {
  String get capitalized => StringUtils.capitalize(this);
  String truncateTo(int maxLength) => StringUtils.truncate(this, maxLength);
  String get initials => StringUtils.initials(this);

  bool get isValidEmail => Validators.isValidEmail(this);
  bool get isValidUrl => Validators.isValidUrl(this);
  bool get isValidHexColor => Validators.isValidHexColor(this);

  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => trim().isNotEmpty;
}
