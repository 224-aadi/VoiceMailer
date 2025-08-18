// import 'package:azure_cognitiveservices_speech_sdk/azure_cognitiveservices_speech_sdk.dart';
// import 'package:flutter/material.dart';

// class MyRecorderApp extends StatefulWidget {
//   @override
//   _MyRecorderAppState createState() => _MyRecorderAppState();
// }

// class _MyRecorderAppState extends State<MyRecorderApp> {
//   bool _isRecording = false;
//   String _recognitionResult = '';
//   String _debugText = '';

//   // Replace these with your Azure credentials
//   final String _azureApiKey = 'YOUR_AZURE_API_KEY';
//   final String _azureRegion = 'YOUR_AZURE_REGION';

//   SpeechRecognizer _speechRecognizer;

//   @override
//   void initState() {
//     super.initState();
//     _initializeSpeechRecognizer();
//   }

//   void _initializeSpeechRecognizer() {
//     _speechRecognizer = SpeechRecognizer(
//       subscription: _azureApiKey,
//       region: _azureRegion,
//     );

//     _speechRecognizer.recognizing = (String result) {
//       setState(() {
//         _recognitionResult = result;
//       });
//     };

//     _speechRecognizer.recognized = (String result) {
//       setState(() {
//         _recognitionResult = result;
//       });
//     };

//     _speechRecognizer.canceled = (String reason) {
//       setState(() {
//         _debugText = 'Recognition canceled: $reason';
//       });
//     };

//     _speechRecognizer.sessionStarted = () {
//       setState(() {
//         _isRecording = true;
//         _debugText = 'Session started';
//       });
//     };

//     _speechRecognizer.sessionStopped = () {
//       setState(() {
//         _isRecording = false;
//         _debugText = 'Session stopped';
//       });
//     };
//   }

//   Future<void> _startRecognition() async {
//     await _speechRecognizer.startContinuousRecognition();
//   }

//   Future<void> _stopRecognition() async {
//     await _speechRecognizer.stopContinuousRecognition();
//   }

//   @override
//   void dispose() {
//     _speechRecognizer.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Real-Time Transcription')),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: _isRecording ? _stopRecognition : _startRecognition,
//             child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text('Recognition Result: $_recognitionResult'),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text('Debug: $_debugText'),
//           ),
//         ],
//       ),
//     );
//   }
// }
