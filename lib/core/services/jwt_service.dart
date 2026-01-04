import 'dart:convert';
import 'package:http/http.dart' as http;

class JwtService {
  static Future<String> fetchJwt({
    required String room,
    required String name,
    required bool moderator,
  }) async {
    final uri = Uri.parse(
      "http://10.0.2.2:3000/jwt"
          "?room=$room"
          "&name=$name"
          "&moderator=$moderator",
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch JWT");
    }

    final data = jsonDecode(response.body);

    // 🔥 THIS IS THE FIX
    return data["token"]; // ✅ return ONLY the JWT string
  }
}
