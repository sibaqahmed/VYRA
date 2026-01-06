import 'dart:convert';
import 'package:http/http.dart' as http;

class JwtService {
  static const String _baseUrl =
      "https://vyra-backend-si7x.onrender.com";

  static Future<String> fetchJwt({
    required String room,
    required String name,
    required bool moderator,
  }) async {
    final uri = Uri.parse(
      "$_baseUrl/jwt"
          "?name=$name"
          "&moderator=$moderator",
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch JWT: ${response.body}");
    }

    final data = jsonDecode(response.body);
    return data["token"];
  }
}
