import 'package:flutter/material.dart';
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
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _encryptedMessageController =
      TextEditingController();
  final TextEditingController _decryptKeyController = TextEditingController();

  String _encryptedMessage = '';
  String _decryptedMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vigenère Cipher'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Message',
                ),
              ),
              TextField(
                controller: _keyController,
                decoration: InputDecoration(
                  labelText: 'Key',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _encryptMessage,
                child: Text('Encrypt'),
              ),
              SizedBox(height: 10),
              Text('Encrypted Message: $_encryptedMessage'),
              Text('Key: ${_keyController.text}'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _encryptedMessage));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied to Clipboard')),
                  );
                },
                child: Text('Copy Encrypted Message'),
              ),
              Divider(height: 40),
              TextField(
                controller: _encryptedMessageController,
                decoration: InputDecoration(
                  labelText: 'Encrypted Message',
                ),
              ),
              TextField(
                controller: _decryptKeyController,
                decoration: InputDecoration(
                  labelText: 'Key for Decryption',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _decryptMessage,
                child: Text('Decrypt'),
              ),
              SizedBox(height: 10),
              Text('Decrypted Message: $_decryptedMessage'),
            ],
          ),
        ),
      ),
    );
  }

  void _encryptMessage() {
    setState(() {
      _encryptedMessage = encrypt(_messageController.text, _keyController.text);
    });
  }

  void _decryptMessage() {
    setState(() {
      _decryptedMessage =
          decrypt(_encryptedMessageController.text, _decryptKeyController.text);
    });
  }
}
