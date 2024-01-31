class PasswordCacheManager {
  const PasswordCacheManager._();

  static String? _cachedPassword;

  static String? get cachedPassword => _cachedPassword;

  static set cachedPassword(String? password) {
    _cachedPassword = password;
    Future.delayed(const Duration(minutes: 15)).then(
      (_) => _cachedPassword = null,
    );
  }
}
