import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'vigenere_cipher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VigenereCipherScreen(),
    );
  }
}

class VigenereCipherScreen extends StatefulWidget {
  @override
  _VigenereCipherScreenState createState() => _VigenereCipherScreenState();
}

class _VigenereCipherScreenState extends State<VigenereCipherScreen> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _decryptKeyController = TextEditingController();

  String _encryptedBase64Audio = '';
  String _decryptedBase64Audio = '';
  String _encryptedFilePath = '';
  String _decryptedFilePath = '';
  String _encryptionKey = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Vigenère Cipher'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _pickAndEncryptAudio,
                child: Text('Pick and Encrypt Audio'),
              ),
              TextField(
                controller: _keyController,
                decoration: InputDecoration(
                  labelText: 'Key',
                ),
              ),
              SizedBox(height: 20),
              if (_encryptedBase64Audio.isNotEmpty) ...[
                Text('Key: $_encryptionKey'),
                Text('Encrypted Audio File: $_encryptedFilePath'),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: _encryptedBase64Audio));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Encrypted audio copied to clipboard')),
                    );
                  },
                  child: Text('Copy Encrypted Audio Base64'),
                ),
                ElevatedButton(
                  onPressed: _saveEncryptedAudio,
                  child: Text('Download Encrypted Audio'),
                ),
              ],
              Divider(height: 40),
              ElevatedButton(
                onPressed: _pickEncryptedAudio,
                child: Text('Upload Encrypted Audio'),
              ),
              TextField(
                controller: _decryptKeyController,
                decoration: InputDecoration(
                  labelText: 'Key for Decryption',
                ),
              ),
              ElevatedButton(
                onPressed: _decryptAudio,
                child: Text('Decrypt Audio'),
              ),
              SizedBox(height: 10),
              if (_decryptedFilePath.isNotEmpty)
                Text('Decrypted Audio File: $_decryptedFilePath'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndEncryptAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String base64Audio = base64Encode(await file.readAsBytes());
      setState(() {
        _encryptionKey = _keyController.text;
        _encryptedBase64Audio = encryptAudio(base64Audio, _encryptionKey);
        _encryptedFilePath = result.files.single.path!;
      });
    }
  }

  Future<void> _saveEncryptedAudio() async {
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final path = '${directory!.path}/encrypted_audio.txt';
      File file = File(path);
      await file.writeAsString(_encryptedBase64Audio);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Encrypted audio saved at $path')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

  Future<void> _pickEncryptedAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String encryptedBase64Audio = await file.readAsString();
      setState(() {
        _encryptedBase64Audio = encryptedBase64Audio;
        _decryptedFilePath = result.files.single.path!;
      });
    }
  }

  void _decryptAudio() async {
    setState(() {
      _decryptedBase64Audio =
          decryptAudio(_encryptedBase64Audio, _decryptKeyController.text);
    });

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/decrypted_audio.mp3';
    File file = File(path);
    await file.writeAsBytes(base64Decode(_decryptedBase64Audio));
    setState(() {
      _decryptedFilePath = path;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Decrypted audio saved at $path')),
    );
  }
}
