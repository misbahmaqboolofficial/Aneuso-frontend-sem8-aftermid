/// Shared form validators for consistent checks across the app.
import 'package:flutter/services.dart';

class PercentInputFormatter extends TextInputFormatter {
  const PercentInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final firstDot = text.indexOf('.');
    if (firstDot >= 0) {
      final intPart = text.substring(0, firstDot);
      final decPart = text.substring(firstDot + 1).replaceAll('.', '');
      text = '$intPart.${decPart.length > 2 ? decPart.substring(0, 2) : decPart}';
    }
    if (text == newValue.text) {
      return newValue;
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class FormValidators {
  FormValidators._();

  static const List<TextInputFormatter> percentInputFormatters = [
    PercentInputFormatter(),
  ];

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9\-]{7,15}$');

  /// Address: at least 5 chars; optional "street, city" comma format when [requireComma] is true.
  static final RegExp _addressCommaRegex = RegExp(r'.+,.+');

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? email(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Please enter your email' : null;
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Please enter a phone number' : null;
    }
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number (7–15 digits)';
    }
    return null;
  }

  static String? name(String? value, {String field = 'Name', int minLength = 2}) {
    final req = required(value, field: field);
    if (req != null) return req;
    if (value!.trim().length < minLength) {
      return '$field must be at least $minLength characters';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final req = required(value, field: 'Confirm password');
    if (req != null) return req;
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? address(
    String? value, {
    bool required = true,
    bool requireComma = false,
    int minLength = 5,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Please enter an address' : null;
    }
    final trimmed = value.trim();
    if (trimmed.length < minLength) {
      return 'Address must be at least $minLength characters';
    }
    if (requireComma && !_addressCommaRegex.hasMatch(trimmed)) {
      return 'Use format: Street/Area, City';
    }
    return null;
  }

  static String? positiveNumber(
    String? value, {
    String field = 'Value',
    bool required = true,
    bool allowZero = false,
    double? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$field is required' : null;
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return '$field must be a valid number';
    }
    if (!allowZero && parsed <= 0) {
      return '$field must be greater than 0';
    }
    if (allowZero && parsed < 0) {
      return '$field cannot be negative';
    }
    if (max != null && parsed > max) {
      return '$field must be at most $max';
    }
    return null;
  }

  static String? positiveInt(
    String? value, {
    String field = 'Value',
    bool required = true,
    bool allowZero = false,
    int? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$field is required' : null;
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return '$field must be a whole number';
    }
    if (!allowZero && parsed <= 0) {
      return '$field must be greater than 0';
    }
    if (allowZero && parsed < 0) {
      return '$field cannot be negative';
    }
    if (max != null && parsed > max) {
      return '$field must be at most $max';
    }
    return null;
  }

  static String? weightKg(String? value, {bool required = true}) {
    return positiveNumber(value, field: 'Weight', required: required, max: 100000);
  }

  static String? price(String? value, {bool required = true}) {
    return positiveNumber(value, field: 'Price', required: required, max: 999999999);
  }

  static String? description(String? value, {int minLength = 10}) {
    final req = required(value, field: 'Description');
    if (req != null) return req;
    if (value!.trim().length < minLength) {
      return 'Description must be at least $minLength characters';
    }
    return null;
  }

  static String? dropdown<T>(T? value, {String field = 'Selection'}) {
    if (value == null) {
      return 'Please select $field';
    }
    return null;
  }

  static String? otpDigit(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }
    if (!RegExp(r'^\d$').hasMatch(value)) {
      return '';
    }
    return null;
  }

  static String? otpCode(String code, {int length = 6}) {
    if (code.length != length) {
      return 'Please enter the full $length-digit code';
    }
    if (!RegExp(r'^\d+$').hasMatch(code)) {
      return 'Code must contain digits only';
    }
    return null;
  }

  static String? discountPercent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Discount is required';
    }
    if (RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Only numbers are allowed';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Only numbers are allowed';
    }
    if (parsed < 0 || parsed > 100) {
      return 'Discount must be between 0 and 100';
    }
    return null;
  }
}
