import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AudioService {
  final String baseUrl;

  AudioService(this.baseUrl);

  Future<Map<String, dynamic>> encryptAudio(File audioFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/encrypt'));
    request.files
        .add(await http.MultipartFile.fromPath('file', audioFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var bytes = await response.stream.toBytes();
      var dir = await getApplicationDocumentsDirectory();
      File file = File('${dir.path}/encrypted_audio.wav');
      await file.writeAsBytes(bytes);

      var responseJson = await http.Response.fromStream(response);
      var json = jsonDecode(responseJson.body);
      String key = json['key'];

      return {'file': file, 'key': key};
    } else {
      throw Exception('Failed to encrypt audio');
    }
  }

  Future<File> decryptAudio(File encryptedFile, String key) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/decrypt'));
    request.files
        .add(await http.MultipartFile.fromPath('file', encryptedFile.path));
    request.fields['key'] = key;

    var response = await request.send();
    if (response.statusCode == 200) {
      var bytes = await response.stream.toBytes();
      var dir = await getApplicationDocumentsDirectory();
      File file = File('${dir.path}/decrypted_audio.wav');
      return file.writeAsBytes(bytes);
    } else {
      throw Exception('Failed to decrypt audio');
    }
  }
}
