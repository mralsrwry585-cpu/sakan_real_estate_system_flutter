import '../localization/app_strings.dart';

/// Client-side form validators. These provide immediate UX feedback only —
/// the backend remains the source of truth for all validation.
class Validators {
  const Validators._();

  static final _emailRegex = RegExp(r'^[\w\.\-\+]+@([\w\-]+\.)+[\w\-]{2,}$');
  // Saudi mobile: 05XXXXXXXX (10 digits) or +9665XXXXXXXX / 9665XXXXXXXX.
  static final _mobileRegex = RegExp(r'^(?:(?:\+?966)|0)?5\d{8}$');

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return S.required;
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return S.required;
    if (!_emailRegex.hasMatch(v)) return S.invalidEmail;
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return S.required;
    if (v.length < 6) return S.shortPassword;
    return null;
  }

  /// Login password: only require non-empty (length rules are for register).
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return S.required;
    return null;
  }

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return S.required;
    if (v.length < 3) return 'الاسم قصير جداً';
    return null;
  }

  static String? mobile(String? value) {
    final v = value?.trim().replaceAll(RegExp(r'[\s\-]'), '') ?? '';
    if (v.isEmpty) return S.required;
    if (!_mobileRegex.hasMatch(v)) return S.invalidMobile;
    return null;
  }

  static String? nationalId(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return S.required;
    if (!RegExp(r'^\d{10}$').hasMatch(v)) {
      return 'رقم الهوية يجب أن يكون 10 أرقام';
    }
    return null;
  }
}
