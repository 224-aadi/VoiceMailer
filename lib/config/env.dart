class Environment {
  // Azure Speech Service Configuration
  static const String azureApiKey = String.fromEnvironment(
    'AZURE_API_KEY',
    defaultValue: 'YOUR_API_KEY_HERE',
  );

  static const String azureRegion = String.fromEnvironment(
    'AZURE_REGION',
    defaultValue: 'westus',
  );

  // App Configuration
  static const String appName = 'Voice Mailer';
  static const String appVersion = '1.0.0';

  // Feature Flags
  static const bool enableDebugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: false,
  );
}
