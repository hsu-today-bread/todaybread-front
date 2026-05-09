class AppConfig {
  AppConfig._();

  static const String _defaultApiBaseUrl = 'http://10.0.2.2:8080';

  static const String _rawApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultApiBaseUrl,
  );

  static const String _rawPaymentCallbackBaseUrl = String.fromEnvironment(
    'PAYMENT_CALLBACK_BASE_URL',
  );

  static String get apiBaseUrl => _normalizeBaseUrl(_rawApiBaseUrl);

  static String get paymentCallbackBaseUrl {
    final value = _rawPaymentCallbackBaseUrl.trim().isEmpty
        ? apiBaseUrl
        : _rawPaymentCallbackBaseUrl;
    return _normalizeBaseUrl(value);
  }

  static String get paymentSuccessUrl =>
      '$paymentCallbackBaseUrl/api/payments/success';

  static String get paymentFailUrl =>
      '$paymentCallbackBaseUrl/api/payments/fail';

  static String _normalizeBaseUrl(String value) {
    var normalized = value.trim();
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }
}
