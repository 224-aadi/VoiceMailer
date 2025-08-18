# Voice Mailer

A Flutter application that allows users to record voice messages and send them via email with speech-to-text transcription capabilities.

## Features

- 🎤 Voice recording with real-time audio visualization
- 📝 Automatic speech-to-text transcription using Azure Speech Services
- 📧 Email integration for sending voice messages
- 💾 Local storage for saved recordings
- 🌙 Dark/Light theme support
- 📱 Cross-platform support (Android, iOS, Web, Desktop)

## Screenshots

[Add screenshots of your app here]

## Prerequisites

- Flutter SDK (>=3.1.0)
- Dart SDK (>=3.1.0)
- Android Studio / VS Code
- Azure Speech Services subscription (for speech-to-text functionality)

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/voice_mailer_new.git
   cd voice_mailer_new
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   Create a `.env` file in the root directory or set environment variables:
   ```bash
   # For development
   export AZURE_API_KEY="your_azure_api_key_here"
   export AZURE_REGION="your_azure_region"
   
   # For Flutter run
   flutter run --dart-define=AZURE_API_KEY=your_key --dart-define=AZURE_REGION=your_region
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## Configuration

### Azure Speech Services Setup

1. Go to [Azure Portal](https://portal.azure.com)
2. Create a Speech Service resource
3. Copy your API key and region
4. Set the environment variables as shown above

### Android Permissions

The app requires the following permissions:
- Microphone access for voice recording
- Storage access for saving recordings
- Internet access for Azure services

## Project Structure

```
lib/
├── main.dart              # App entry point
├── Homepage.dart          # Main home screen
├── Homepage_realTime.dart # Real-time recording screen
├── login.dart            # Login screen
├── saved.dart            # Saved recordings screen
├── setting.dart          # Settings screen
├── change_email.dart     # Email configuration
├── check.dart            # Permission checks
└── config/
    └── env.dart          # Environment configuration
```

## Dependencies

Key packages used:
- `record`: Audio recording
- `flutter_ffmpeg`: Audio processing
- `shared_preferences`: Local storage
- `flutter_email_sender`: Email functionality
- `connectivity_plus`: Network connectivity
- `http`: HTTP requests
- `speech_to_text`: Speech recognition

## Building for Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions:
1. Check the [Issues](https://github.com/yourusername/voice_mailer_new/issues) page
2. Create a new issue with detailed information
3. Contact the maintainers

## Acknowledgments

- Flutter team for the amazing framework
- Azure Speech Services for speech recognition
- All the package contributors

---

**Note**: Make sure to replace `yourusername` with your actual GitHub username in the URLs above.
