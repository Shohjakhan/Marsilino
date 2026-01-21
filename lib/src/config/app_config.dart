/// Application configuration.
class AppConfig {
  /// Base URL for the API.
  /// Change this for different environments (dev, staging, prod).
  static const String apiBaseUrl = 'https://marsilino.onrender.com';

  /// API version prefix.
  static const String apiPrefix = '/api';

  /// Full API base URL.
  static String get apiUrl => '$apiBaseUrl$apiPrefix';

  /// Request timeout in seconds.
  static const int requestTimeout = 30;

  /// Enable debug logging.
  static const bool debugMode = true;
}
