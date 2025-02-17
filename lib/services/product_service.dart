import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductService {
  Future<List<dynamic>> getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('odoo_url');
    String? database = prefs.getString('odoo_database');
    String? sessionId = prefs.getString('odoo_session_id');
    if (url == null || database == null || sessionId == null) {
      throw Exception('Missing configuration or session data');
    }
    final response = await http.post(
      Uri.parse('$url/web/dataset/call_kw'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'model': 'product.product',
          'method': 'search_read',
          'args': [
            [],
            ['name', 'list_price', 'barcode']
          ],
          'kwargs': {'context': {}}
        },
        'id': 1,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result'] as List<dynamic>;
    } else {
      throw Exception('Failed to load products');
    }
  }
}
