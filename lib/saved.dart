// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_mailer_new/Homepage.dart';
import 'package:voice_mailer_new/setting.dart';

class SavedRecordings extends StatefulWidget {
  @override
  SavedRecordingsState createState() => SavedRecordingsState();
}

class SavedRecordingsState extends State<SavedRecordings> {
  List<Map<String, dynamic>> audioFiles = [];
  AudioPlayer audioPlayer = AudioPlayer();
  File? playingFile;
  bool isPlaying = false;
  bool _isLoading = true;

  int _currentIndex = 1; // Index for the 'Saved' page

  late SharedPreferences prefs;
  late String givenEmail;

  @override
  void initState() {
    super.initState();
    listAudioFiles();
    setupAudioPlayer();
    get_email();
  }

  void get_email() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      givenEmail = prefs.getString('email') ?? 'Enter Email';
    });
  }

  void setupAudioPlayer() {
    audioPlayer.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
        if (state.processingState == ProcessingState.completed) {
          playingFile = null;
        }
      });
    });
  }

  void listAudioFiles() async {
    try {
      Directory? appDirectory = await getExternalStorageDirectory();
      if (appDirectory != null) {
        List<FileSystemEntity> files = appDirectory.listSync(recursive: true);
        List<Map<String, dynamic>> m4aFiles = [];
        // List<Map<String, dynamic>> txtFiles = [];

        for (FileSystemEntity file in files) {
          if (file is File && file.path.endsWith('.wav')) {
            Duration? duration = await _getAudioDuration(file);

            // Load the corresponding .txt file
            String txtFilePath = file.path.replaceAll('.wav', '.txt');
            String? txtContent;
            if (File(txtFilePath).existsSync()) {
              txtContent = await File(txtFilePath).readAsString();
            } else {
              txtContent = 'No transcript available';
            }

            // Add both the .wav and .txt files to the list
            m4aFiles.insert(0, {
              'audioFile': file,
              'duration': duration,
              'txtFile': File(txtFilePath),
              'transcript': txtContent,
            });
          }
        }
        setState(() {
          audioFiles = m4aFiles;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error listing audio files: $e");
    }
  }

  Future<Duration?> _getAudioDuration(File file) async {
    try {
      final player = AudioPlayer();
      await player.setFilePath(file.path);
      Duration? duration = player.duration;
      await player.dispose(); // Dispose the player after getting the duration
      return duration;
    } catch (e) {
      print("Error getting audio duration: $e");
      return null;
    }
  }

  String formatDuration(Duration? duration) {
    if (duration == null) return "00:00:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> playPauseAudio(File file) async {
    try {
      if (isPlaying && playingFile == file) {
        await audioPlayer.pause();
        setState(() {
          isPlaying = false;
        });
      } else {
        if (playingFile != file) {
          setState(() {
            playingFile = file;
            isPlaying = false;
          });
          await audioPlayer.setFilePath(file.path);
        }
        await audioPlayer.play();
        setState(() {
          isPlaying = true;
          playingFile = file;
        });
      }

      // Listen to the player state stream
      audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          setState(() {
            isPlaying = false;
            playingFile = null; // or keep it as is based on your needs
          });
        }
      });
    } catch (e) {
      print("Error playing/pausing audio: $e");
    }
  }

  Future<void> stopAudio() async {
    try {
      await audioPlayer.stop();
      setState(() {
        isPlaying = false;
        playingFile = null;
      });
    } catch (e) {
      print("Error stopping audio: $e");
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _sendEmailWithAttachment(
      String filePath, String transcript) async {
    String fileName = filePath.split('/').last;
    int dotIndex = fileName.indexOf('.');
    String result =
        fileName.substring(0, dotIndex); // Extract the file name till '.'
    debugPrint(prefs.getString('email').toString());
    final Email email = Email(
      body:
          // 'Please find the attached audio recording.',
          'Please find the attached audio recording.\n\nTranscription:\n$transcript', // Replace with the email body text
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
        title: Text('Saved Recordings'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Recent Recordings',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: audioFiles.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> fileData = audioFiles[index];
                        File audioFile = fileData['audioFile'];
                        Duration? duration = fileData['duration'];
                        File txtFile = fileData['txtFile'];
                        String transcript = fileData['transcript'];

                        String audioFileName = audioFile.path.split('/').last;
                        String txtFileName = txtFile.path.split('/').last;
                        String durationString = formatDuration(duration);

                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Sending $audioFileName and $txtFileName via email...'),
                              ),
                            );
                            // String filePath =
                            //     await getExternalStorageDirectory().toString() +
                            //         audioFiles[index].toString();
                            var result =
                                await Connectivity().checkConnectivity();

                            if (!(result == ConnectivityResult.none)) {
                              print('Valid Internet Connection');
                              _sendEmailWithAttachment(
                                  audioFile.path.toString(), transcript);
                            } else {
                              print(result);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'No Internet. The Recording has been saved.'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          background: Container(
                            color: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.email,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          child: Card(
                            elevation: 2,
                            child: ListTile(
                              title: Text(
                                'Recording: $audioFileName',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Duration: $durationString'),
                                  SizedBox(height: 5),
                                  Text('Transcript: $transcript'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isPlaying && playingFile == audioFile
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => playPauseAudio(audioFile),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Set the current index
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Handle navigation based on index
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false, // Remove all previous routes
            );
          } else if (index == 1) {
            // Stay on the same page (Saved Recordings)
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
