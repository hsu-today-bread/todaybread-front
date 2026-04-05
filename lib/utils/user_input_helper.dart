import 'package:flutter/services.dart';

/// 사용자 입력값을 백엔드 규격에 맞게 정리하는 유틸입니다.
class UserInputHelper {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _phonePattern = RegExp(r'^01[016789]-\d{3,4}-\d{4}$');

  static const int minPasswordLength = 10;

  static bool isValidEmail(String value) =>
      _emailPattern.hasMatch(value.trim());

  static bool isValidPhoneNumber(String value) =>
      _phonePattern.hasMatch(normalizePhoneNumber(value));

  static String normalizePhoneNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return '';
    }

    final safeDigits = digits.length > 11 ? digits.substring(0, 11) : digits;
    if (safeDigits.length <= 3) {
      return safeDigits;
    }

    if (safeDigits.length <= 7) {
      return '${safeDigits.substring(0, 3)}-${safeDigits.substring(3)}';
    }

    final middleLength = safeDigits.length == 10 ? 3 : 4;
    final secondChunkEnd = 3 + middleLength;

    return '${safeDigits.substring(0, 3)}-'
        '${safeDigits.substring(3, secondChunkEnd)}-'
        '${safeDigits.substring(secondChunkEnd)}';
  }
}

/// 전화번호를 `010-1234-5678` 형태로 맞추는 입력 포매터입니다.
class PhoneNumberTextInputFormatter extends TextInputFormatter {
  const PhoneNumberTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = UserInputHelper.normalizePhoneNumber(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
