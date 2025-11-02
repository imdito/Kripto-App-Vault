import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SuperEncryptService {
  final String? baseUrl = dotenv.env['API_HOST'];

  Future<Map<String, dynamic>> encrypt({
    required String text,
    int caesarShift = 3,
    String vigenereKey = 'KEY',
    String desKey = 'secret12',
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
      };
    } else {
      throw Exception(result['message']);
    }
  }

  Future<String> decrypt(Map<String, dynamic> encryptedData) async {
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