/// Application configuration.
class AppConfig {
  /// Base URL for the API.
  /// Change this for different environments (dev, staging, prod).
  static const String apiBaseUrl = 'http://127.0.0.1:8000';

  /// API version prefix.
  static const String apiPrefix = '/api';

  /// Full API base URL.
  static String get apiUrl => '$apiBaseUrl$apiPrefix';

  /// Request timeout in seconds.
  static const int requestTimeout = 30;

  /// Enable debug logging.
  static const bool debugMode = true;
}
