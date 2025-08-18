import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  // Azure Speech Service Configuration
  static String get azureApiKey =>
      dotenv.env['AZURE_API_KEY'] ?? 'YOUR_API_KEY_HERE';
  static String get azureRegion => dotenv.env['AZURE_REGION'] ?? 'westus';

  // App Configuration
  static const String appName = 'Voice Mailer';
  static const String appVersion = '1.0.0';

  // Feature Flags
  static bool get enableDebugMode => dotenv.env['DEBUG_MODE'] == 'true';
}
