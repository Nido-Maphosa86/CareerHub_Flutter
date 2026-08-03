// lib/config/app_config.dart
//
// Compile-time environment configuration. Every value here is read via
// String.fromEnvironment / bool.fromEnvironment, which Dart resolves at
// compile time from --dart-define-from-file=config.dev.json or
// config.prod.json. None of these are runtime lookups — the values are
// baked into the compiled binary before it ever runs, so a dev build can
// never accidentally pick up the prod URL (or vice versa) based on device
// state, and there is no file read or environment variable lookup at launch.

class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
  );

  static bool get isProduction => environment == 'prod';
}
