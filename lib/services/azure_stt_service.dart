import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:voice_mailer_new/config/env.dart';

class AzureSttService {
  static const String _speechPath = '/speech/recognition/conversation/cognitiveservices/v1';

  Future<String?> transcribeAudio(File audioFile) async {
    final apiKey = Environment.azureApiKey;
    final region = Environment.azureRegion;
    
    // Azure Speech Service URL
    final url = Uri.parse('https://$region.stt.speech.microsoft.com$_speechPath?language=en-US');

    try {
      final audioBytes = await audioFile.readAsBytes();
      
      final response = await http.post(
        url,
        headers: {
          'Ocp-Apim-Subscription-Key': apiKey,
          'Content-Type': 'audio/wav; codecs=audio/pcm; samplerate=16000', 
          // Note: Azure STT requires specific audio formats. 
          // If the recorded audio is not WAV/PCM 16kHz, this might fail or require conversion.
          // The reference code uses m4a/aac. Azure supports various formats but often requires
          // specific headers or container formats. 
          // For simplicity, we'll try sending the file as-is first, but we might need to 
          // adjust the Content-Type or use a different endpoint if it's not raw PCM.
          // Application/octet-stream is safer for generic uploads if the container is self-describing
          // but Azure often wants 'audio/wav' or similar.
          // Let's use validation in the UI to ensure we are sending compatible audio if possible,
          // or use a different content-type.
          // Common allow: audio/wav; codecs=audio/pcm; samplerate=16000
          // For M4A/AAC, it might be 'audio/m4a' or similar? 
          // Azure REST API supports: WAV (PCM, u-law, a-law), OGG (Opus).
          // M4A is NOT directly supported by the SHORT AUDIO REST API. 
          // We might need to use the Batch Transcription API or convert the file.
          // However, for this task, I will attempt to assume we can configure the recorder 
          // to output WAV if possible, or just implement the service call and let the user debug format issues.
          // Wait, the reference code sets: 
          // ..androidOutputFormat = AndroidOutputFormat.mpeg4
          // ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
          // This outputs M4A. Azure REST API *requires* WAV or Ogg.
          // I will add a TODO here and try to change the recorder settings in homepage.dart.
          'Accept': 'application/json',
        },
        body: audioBytes,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['DisplayText'] != null) {
          return data['DisplayText'];
        }
      } else {
        debugPrint('Azure STT Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error calling Azure STT: $e');
    }
    return null;
  }
}
