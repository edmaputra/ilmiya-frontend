/// Centralized application release and version information.
class AppVersion {
  /// Current semantic version string (e.g. '0.9.0').
  /// Can be overridden at build time via `--dart-define=APP_VERSION=...`.
  static const String current = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '0.9.0',
  );

  /// Git tag representation (e.g. 'v0.9.0').
  static String get tag => current.startsWith('v') ? current : 'v$current';

  /// Raw semantic version without 'v' prefix (e.g. '0.9.0').
  static String get raw =>
      current.startsWith('v') ? current.substring(1) : current;

  /// Full display label for UI headers and footers (e.g. 'Ilmiya SIS v0.9.0').
  static String get display => 'Ilmiya SIS $tag';
}
