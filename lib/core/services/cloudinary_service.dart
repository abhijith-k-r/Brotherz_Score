import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = "dog5j8kkr"; 
  static const String uploadPreset = "brotherz_score_upload";

  static Future<String?> uploadImage(File file) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    
    final request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'] as String;
      }
    } catch (e) {
      // print("Cloudinary Upload Error: $e");
    }
    return null;
  }

  // NOTE: Unsigned deletion is NOT supported via standard REST API without a signature/API secret.
  // For security, unsigned presets are usually upload-only. 
  // If deletion is required for storage management, it should be done via a Cloudinary cleanup rule or a secure backend.
}
