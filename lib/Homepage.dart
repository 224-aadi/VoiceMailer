// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_mailer_new/saved.dart';
import 'package:voice_mailer_new/setting.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:voice_mailer_new/config/env.dart';

//Add Snackbar errors for each error

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Index for the 'Saved' page

  final record = AudioRecorder();
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  final List<double> _amplitudeHistory = [];
  double _maxAmplitude = 1.0;
  bool _isRecording = false;
  // String? _recordingPath;
  String _debugText = '';
  late SharedPreferences prefs;
  late String givenEmail;
  bool _isGenerating = false;

  String _recognitionResult = '';

  // Azure Speech Service Configuration - Loaded from environment
  String _azureApiKey = Environment.azureApiKey;
  String _azureRegion = Environment.azureRegion;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    get_email();
  }

  @override
  void dispose() {
    record.dispose();
    _flutterFFmpeg.cancel();
    super.dispose();
  }

  void get_email() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      givenEmail = prefs.getString('email') ?? 'Enter Email';
    });
  }

  Future<void> _checkPermission() async {
    if (!await record.hasPermission()) {
      setState(() {
        _debugText = 'Microphone permission not granted';
      });
    } else {
      setState(() {
        _debugText = 'Microphone permission granted';
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await record.hasPermission()) {
        final directory = await getExternalStorageDirectory();
        String time_atRecording = DateTime.now().toString();
        String _recordingPath = '${directory?.path}/$time_atRecording.m4a';

        await record.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
            numChannels: 2,
          ),
          path: _recordingPath,
        );

        setState(() {
          _isRecording = true;
          _amplitudeHistory.clear();
          _maxAmplitude = 1.0;
          _debugText = 'Recording started';
          _recognitionResult = '';
        });

        record
            .onAmplitudeChanged(const Duration(milliseconds: 50))
            .listen((amplitude) {
          if (mounted) {
            double normalizedAmplitude = (amplitude.current / 32767.0).abs();

            // Update max amplitude with decay
            _maxAmplitude = math.max(_maxAmplitude * 0.95, normalizedAmplitude);

            // Apply scaling
            normalizedAmplitude =
                (normalizedAmplitude / _maxAmplitude).clamp(0.0, 1.0);

            setState(() {
              if (_amplitudeHistory.length >= 100) {
                // Increased to show more data
                _amplitudeHistory.removeAt(0);
              }
              _amplitudeHistory.add(normalizedAmplitude);
            });
          }
        });
      } else {
        setState(() {
          _debugText = 'Recording permission not granted';
        });
      }
    } catch (e) {
      setState(() {
        _debugText = 'Error starting recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await record.stop();
      String fileName = path.toString().split('/').last;
      int dotIndex = fileName.indexOf('.');
      String time_ofPath =
          fileName.substring(0, dotIndex); // Extract the file name till '.'
      final wavPath = await _convertToWav(path.toString(), time_ofPath);
      _recognizeSpeech(wavPath.toString(), time_ofPath);
      setState(() {
        _isRecording = false;
        _debugText = 'Recording stopped. File saved at: $path';
      });
    } catch (e) {
      setState(() {
        _debugText = 'Error stopping recording: $e';
      });
    }
  }

  Future<String?> _convertToWav(String m4aPath, time) async {
    final directory = await getExternalStorageDirectory();
    final wavPath = '${directory?.path}/$time.wav';

    final arguments = ['-i', m4aPath, wavPath];
    final result = await _flutterFFmpeg.executeWithArguments(arguments);

    if (result == 0) {
      return wavPath;
    } else {
      print('Error converting file: $result');
      return null;
    }
  }

  Future<void> _recognizeSpeech(String filePath, time) async {
    // Check internet connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'No internet connection. Please check your network settings.'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isGenerating = false;
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _recognitionResult = 'Generating Text...';
    });

    final bytes = File(filePath).readAsBytesSync();
    final url = Uri.parse(
        'https://${_azureRegion}.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-IN');

    try {
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $_azureApiKey',
          HttpHeaders.contentTypeHeader: 'audio/wav',
          'Ocp-Apim-Subscription-Key': _azureApiKey,
        },
        body: bytes,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _isGenerating = false;
          _recognitionResult = data['DisplayText'] ?? 'No text recognized';
          saveTranscription(time);
          _sendEmailWithAttachment(filePath.toString());
        });
      } else {
        setState(() {
          _recognitionResult = 'Recognition failed: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _recognitionResult = 'An error occurred: $e';
      });
    }
  }

  void saveTranscription(time) async {
    //Save the text as a .txt file as well
    final directory = await getExternalStorageDirectory();
    final txtPath = '${directory?.path}/$time.txt';
    final file = File(txtPath);
    await file.writeAsString(_recognitionResult);
  }

  Future<void> _sendEmailWithAttachment(String filePath) async {
    String fileName = filePath.split('/').last;
    int dotIndex = fileName.indexOf('.');
    String result =
        fileName.substring(0, dotIndex); // Extract the file name till '.'
    debugPrint(prefs.getString('email').toString());
    final Email email = Email(
      body:
          'Please find the attached audio recording.\n\nTranscription:\n$_recognitionResult', // Replace with the email body text
      subject: "VoiceMailer: $result", // Replace with the subject of the email
      recipients: [
        prefs.getString('email').toString()
      ], // Replace with recipient email address(es)
      attachmentPaths: [filePath],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      print('Email sent');

      // Attempt to delete the file after invoking the email client
      //DELETE THE .M4A, wav and txt file
      // final file = File(filePath);
      // if (await file.exists()) {
      //   await file.delete();
      //   print('Recording deleted');
      // }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email sent successfully'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error sending email: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An Error Occured. The Recording is saved'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VoiceMailer'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome to VoiceMailer',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _isRecording
                  ? Container(
                      height: 200,
                      child: CustomPaint(
                        painter: BarcodeWaveformPainter(_amplitudeHistory),
                        size: Size(MediaQuery.of(context).size.width - 32, 200),
                      ),
                    )
                  : Container(),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.orange,
                ),
                child:
                    Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
              ),
              SizedBox(height: 16),
              // Text(_debugText, style: TextStyle(color: Colors.red)),
              _isGenerating
                  ? Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      shadowColor: Colors.grey.withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _isGenerating
                                ? CircularProgressIndicator()
                                : Container(),
                            SizedBox(height: 16),
                            Text(
                              _recognitionResult,
                              textAlign: TextAlign
                                  .center, // Center the text inside the Text widget
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold, // Optional: Bold text
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            // Stay on the same page (Home)
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SavedRecordings()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class BarcodeWaveformPainter extends CustomPainter {
  final List<double> amplitudes;

  BarcodeWaveformPainter(this.amplitudes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final midHeight = size.height / 2;
    final widthPerSample = size.width / amplitudes.length;

    path.moveTo(0, midHeight);

    for (int i = 0; i < amplitudes.length - 1; i++) {
      final x1 = i * widthPerSample;
      final y1 = midHeight - amplitudes[i] * midHeight;

      final x2 = (i + 1) * widthPerSample;
      final y2 = midHeight - amplitudes[i + 1] * midHeight;

      final controlPointX = (x1 + x2) / 2;
      final controlPointY = (y1 + y2) / 2;

      path.quadraticBezierTo(controlPointX, controlPointY, x2, y2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/*
import 'package:azure_cognitiveservices_speech/azure_cognitiveservices_speech.dart';

  String _recognitionResult = '';


  // Azure Speech SDK variables
  late SpeechConfig _speechConfig;
  late AudioConfig _audioConfig;
  late SpeechRecognizer _speechRecognizer;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    get_email();
    _initializeSpeechSDK();
  }

  @override
  void dispose() {
    record.dispose();
    _speechRecognizer.dispose();
    super.dispose();
  }

  Future<void> _initializeSpeechSDK() async {
    // Replace with your Azure Speech Service subscription key and region
    _speechConfig = SpeechConfig(
        subscriptionKey: "YOUR_SUBSCRIPTION_KEY", region: "YOUR_REGION");
    _speechConfig.speechRecognitionLanguage = "hi-IN"; // Set to Hindi

    _audioConfig = AudioConfig(useDefaultMicrophone: true);
    _speechRecognizer = SpeechRecognizer(_speechConfig, _audioConfig);

    _speechRecognizer.recognizing.listen((event) {
      setState(() {
        _recognitionResult = event.result.text;
      });
    });

    _speechRecognizer.recognized.listen((event) {
      setState(() {
        _recognitionResult += event.result.text + " ";
      });
    });
  }

  
  Future<void> _startRecording() async {
    SAME AS BEFORE

        setState(() {
          _isRecording = true;
          _amplitudeHistory.clear();
          _maxAmplitude = 1.0;
          _debugText = 'Recording started';
          _recognitionResult = '';
        });

        // Start speech recognition
        await _speechRecognizer.startContinuousRecognitionAsync();

        record
            .onAmplitudeChanged(const Duration(milliseconds: 50))
            .listen((amplitude) {
          if (mounted) {
            double normalizedAmplitude = (amplitude.current / 32767.0).abs();
            _maxAmplitude = math.max(_maxAmplitude * 0.95, normalizedAmplitude);
            normalizedAmplitude =
                (normalizedAmplitude / _maxAmplitude).clamp(0.0, 1.0);

            setState(() {
              if (_amplitudeHistory.length >= 100) {
                _amplitudeHistory.removeAt(0);
              }
              _amplitudeHistory.add(normalizedAmplitude);
            });
          }
        });
      } else {
        setState(() {
          _debugText = 'Recording permission not granted';
        });
      }
    } catch (e) {
      setState(() {
        _debugText = 'Error starting recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await record.stop();
      await _speechRecognizer.stopContinuousRecognitionAsync();
  }
}
 */