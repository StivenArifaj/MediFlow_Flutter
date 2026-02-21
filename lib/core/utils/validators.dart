class AppValidators {
  AppValidators._();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static bool isValidEmail(String? value) {
    if (value == null || value.isEmpty) return false;
    return _emailRegex.hasMatch(value.trim());
  }
}
