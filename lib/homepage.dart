import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_audio/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_mailer_new/saved.dart';
import 'package:voice_mailer_new/setting.dart';
import 'package:voice_mailer_new/services/azure_stt_service.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SharedPreferences prefs;
  late final RecorderController recorderController;
  final AzureSttService _azureSttService = AzureSttService();

  String? path;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;
  late Directory appDirectory;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initialiseControllers();
    _initPrefs();
  }

  void _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _initialiseControllers() {
    recorderController = RecorderController();
  }

  @override
  void dispose() {
    recorderController.dispose();
    super.dispose();
  }

  Future<String> _getDir(String time) async {
    Directory appDirectory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    return "${appDirectory.path}/$time.m4a";
  }

  Future<void> _startOrStopRecording() async {
    try {
      if (isRecording) {
        // Stop Recording
        final path = await recorderController.stop(false);
        
        setState(() {
          isRecording = false;
        });

        if (path != null) {
          isRecordingCompleted = true;
          debugPrint("Recorded path: $path");
          
          final File m4aFile = File(path);
          if (m4aFile.existsSync()) {
            debugPrint("Recorded file size: ${m4aFile.lengthSync()}");
            
            // Convert m4a to wav for Azure
            final String wavPath = path.replaceAll('.m4a', '.wav');
            await _convertM4aToWav(path, wavPath);
            
            // Transcribe
            String transcript = "No transcript available";
            final connectivityResult = await Connectivity().checkConnectivity();
            
            if (connectivityResult != ConnectivityResult.none) {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transcribing audio...')),
              );
              
              final File wavFile = File(wavPath);
              if (wavFile.existsSync()) {
                final sttResult = await _azureSttService.transcribeAudio(wavFile);
                if (sttResult != null) {
                  transcript = sttResult;
                  debugPrint("Transcript: $transcript");
                }
              }
            } else {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No Internet. Saved without transcript.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            
            // Save transcript to .txt file
            final String txtPath = path.replaceAll('.m4a', '.txt'); 
            
            final File txtFile = File(txtPath);
            await txtFile.writeAsString(transcript);
            
            // Attempt to send email with the WAV file (more compatible) and Transcript
            if (connectivityResult != ConnectivityResult.none) {
               await _sendEmailWithAttachment(wavPath, transcript);
            }

          }
        }
      } else {
        // Start Recording
        final status = await recorderController.checkPermission();
        if (status) {
          String time2 = DateTime.now().millisecondsSinceEpoch.toString();
          String newPath = await _getDir(time2);
          
          await recorderController.record(path: newPath);
           setState(() {
            isRecording = true;
          });
        } else {
          debugPrint("No permission to record");
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isRecording = false;
      });
    }
  }

  Future<void> _convertM4aToWav(String inputPath, String outputPath) async {
    // -y to overwrite output file
    final command = '-y -i "$inputPath" "$outputPath"';
    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint("FFmpeg process exited with success");
      } else {
        debugPrint("FFmpeg process exited with rc $returnCode");
      }
    });
  }

  Future<void> _sendEmailWithAttachment(String filePath, String transcript) async {
    String fileName = filePath.split('/').last;
    
    final Email email = Email(
      body: 'Please find the attached audio recording.\n\nTranscript:\n$transcript', 
      subject: "VoiceMailer: $fileName", 
      recipients: [prefs.getString('email') ?? ''], 
      attachmentPaths: [filePath],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error sending email. Recording saved.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(title: const Text('VoiceMailer'), elevation: 0, backgroundColor: Colors.amber),
      body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isRecording
                          ? AudioWaveforms(
                        enableGesture: true,
                        size: Size(MediaQuery.of(context).size.width, 100),
                        recorderController: recorderController,
                        waveStyle: const WaveStyle(
                          waveColor: Colors.black87,
                          extendWaveform: true,
                          showMiddleLine: false,
                        ),
                        padding: const EdgeInsets.only(left: 18),
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                      ) : Container(
                        padding: EdgeInsets.only(bottom: (MediaQuery.of(context).size.width/20)),
                        child: ElevatedButton(
                          onPressed: _startOrStopRecording,
                          style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                              backgroundColor: Colors.black87
                          ),
                          child: Icon((Icons.mic), color: Colors.white, size: MediaQuery.of(context).size.width / 12,),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isRecording)
                  Container(
                    padding: EdgeInsets.only(bottom: (MediaQuery.of(context).size.width/5)),
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: _startOrStopRecording,
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: Colors.black87
                      ),
                      child: Icon((Icons.stop), color: Colors.white, size: MediaQuery.of(context).size.width / 12,),
                    ),
                  ),
              ],
            ),
          ],
        ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            // Stay on Home
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SavedRecordings()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }
        },
        items: const <BottomNavigationBarItem>[
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
