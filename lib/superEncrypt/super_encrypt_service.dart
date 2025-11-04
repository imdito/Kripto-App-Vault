import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SuperEncryptService {
  final String? baseUrl = dotenv.env['API_HOST'];

  Future<Map<String, dynamic>> encrypt({
    required String text,
    required int caesarShift,
    required String vigenereKey,
    required String desKey,
  }) async {
    print("base url: $baseUrl");
    final response = await http.post(
      Uri.parse('$baseUrl/api/super-encrypt'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'text': text,
        'caesar_shift': caesarShift,
        'vigenere_key': vigenereKey,
        'des_key': desKey,
      }),
    );

    final result = jsonDecode(response.body);

    if (result['success']) {
      return {
        'ciphertext': result['data']['ciphertext'],
        'iv': result['data']['iv'],
        'caesar_shift': caesarShift,
        'vigenere_key': vigenereKey,
        'des_key': desKey,
        'iv': result['data']['iv'],
      };
    } else {
      throw Exception(result['message']);
    }
  }

  Future<String> decrypt({
    required String chiperText,
    required int caesarShift,
    required String vigenereKey,
    required String desKey,
    required String iv,
}) async {
    Map<String, dynamic> encryptedData = {
      'ciphertext': chiperText,
      'caesar_shift': caesarShift,
      'vigenere_key': vigenereKey,
      'des_key': desKey,
      'iv': iv,
    };
    final response = await http.post(
      Uri.parse('$baseUrl/api/super-decrypt'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(encryptedData),
    );

    final result = jsonDecode(response.body);

    if (result['success']) {
      return result['data']['plaintext'];
    } else {
      if (result['error_type'] == 'WRONG_KEY') {
        throw Exception('Wrong encryption keys!');
      }
      throw Exception(result['message']);
    }
  }
}