import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  Future<bool> login(String username, String password, String database) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('odoo_url');
    if (url == null || url.isEmpty) return false;
    final response = await http.post(
      Uri.parse('$url/web/session/authenticate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'params': {
          'db': database,
          'login': username,
          'password': password,
        }
      }),
    );
    if (response.statusCode == 200) {
      final cookie = response.headers['set-cookie'];
      if (cookie != null) {
        final sessionIdRegExp = RegExp(r'session_id=([^;]+)');
        final match = sessionIdRegExp.firstMatch(cookie);
        if (match != null) {
          String sessionId = match.group(1)!;
          await prefs.setString('odoo_session_id', sessionId);
        }
      }
      final data = jsonDecode(response.body);
      return data['result'] != null;
    } else {
      return false;
    }
  }
}
