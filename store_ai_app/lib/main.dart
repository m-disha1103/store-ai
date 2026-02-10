import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const StoreAIApp());
}

class StoreAIApp extends StatelessWidget {
  const StoreAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

// 🔹 StatefulWidget (VERY IMPORTANT)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int quantity = 0;
  double price = 0.0;
  String result = "";

  // 🔹 Backend call
  Future<void> predictSales() async {
    final url = Uri.parse('http://127.0.0.1:5000/predict');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'quantity': quantity,
          'price': price,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          result = "Predicted Sales: ${data['prediction']}";
        });
      } else {
        setState(() {
          result = "Server Error";
        });
      }
    } catch (e) {
      setState(() {
        result = "Backend not reachable";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Store Management"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity"),
              onChanged: (value) {
                quantity = int.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
              onChanged: (value) {
                price = double.tryParse(value) ?? 0.0;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: predictSales,
              child: const Text("Predict Sales"),
            ),
            const SizedBox(height: 20),
            Text(
              result,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
