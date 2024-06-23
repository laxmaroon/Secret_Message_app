import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'audio_sv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart'; // Add this for sharing the file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioService audioService = AudioService('http://10.0.2.2:5000');
  File? selectedFile;
  String? encryptionKey;
  File? encryptedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _encryptFile() async {
    if (selectedFile != null) {
      var result = await audioService.encryptAudio(selectedFile!);
      setState(() {
        encryptedFile = result['file'];
        encryptionKey = result['key'];
      });

      // Show a message or a snackbar to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('File encrypted successfully! Key: $encryptionKey')));
    }
  }

  Future<void> _decryptFile() async {
    if (encryptedFile != null && encryptionKey != null) {
      File decryptedFile =
          await audioService.decryptAudio(encryptedFile!, encryptionKey!);
      // Handle the decrypted file as needed
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File decrypted successfully!')));
    }
  }

  Future<void> _downloadFile(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${file.path.split('/').last}';
    final savedFile = await file.copy(filePath);

    // Share the file using Share Plus
    await Share.shareFiles([savedFile.path]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Encrypt/Decrypt'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Pick Audio File'),
            ),
            ElevatedButton(
              onPressed: _encryptFile,
              child: Text('Encrypt Audio File'),
            ),
            if (encryptionKey != null)
              Column(
                children: [
                  Text('Encryption Key: $encryptionKey'),
                  ElevatedButton(
                    onPressed: () {
                      if (encryptedFile != null) {
                        _downloadFile(encryptedFile!);
                      }
                    },
                    child: Text('Download Encrypted File'),
                  ),
                ],
              ),
            ElevatedButton(
              onPressed: _decryptFile,
              child: Text('Decrypt Audio File'),
            ),
          ],
        ),
      ),
    );
  }
}
