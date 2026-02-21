import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.29.126:5000";

  static Future<double?> predictSales({
    required String product,
    required int quantity,
    required double price,
  }) async {
    final url = Uri.parse("$baseUrl/predict");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "product": product,
        "quantity": quantity,
        "price": price,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return double.parse(data["prediction"].toString());
    } 
    return null;
    
  }
}