import '../core/constants/app_strings.dart';

class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.emailRequired;
    if (!_emailRegex.hasMatch(value.trim())) return AppStrings.emailInvalid;
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.phoneRequired;
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    if (!_phoneRegex.hasMatch(cleaned)) return AppStrings.phoneInvalid;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return AppStrings.passwordRequired;
    if (value.length < 8) return AppStrings.passwordWeak;
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return AppStrings.passwordRequired;
    if (value != original) return AppStrings.passwordsDoNotMatch;
    return null;
  }

  static String? minLength(String? value, int min) {
    if (value == null || value.trim().length < min) {
      return 'Must be at least $min characters';
    }
    return null;
  }

  static String? otp(String? value, {int length = 6}) {
    if (value == null || value.length != length) return 'Enter $length-digit code';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Digits only';
    return null;
  }

  static String? notEmptyList(List? list) {
    if (list == null || list.isEmpty) return AppStrings.fieldRequired;
    return null;
  }
}
