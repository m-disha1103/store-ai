import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const StoreAIApp());
}

class StoreAIApp extends StatelessWidget {
  const StoreAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedProduct = "Product A";
  final String baseUrl = "http://192.168.29.126:5000";
  List<Map<String, String>> history = [];

  List<String> products = [
    "Product A",
  ];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController productController = TextEditingController();

  String result = "";
  bool isLoading = false;

  @override
void initState() {
  super.initState();
  loadHistory();
}

  Future<void> saveHistory() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> historyList =
      history.map((item) => jsonEncode(item)).toList();
  await prefs.setStringList('sales_history', historyList);
}

Future<void> loadHistory() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? historyList = prefs.getStringList('sales_history');

  if (historyList != null) {
    setState(() {
      history = historyList
          .map((item) => Map<String, String>.from(jsonDecode(item)))
          .toList();
    });
  }
}
  
  Future<void> predictSales() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      result = "";
    });

    final url = Uri.parse("http://192.168.29.126:5000/predict");

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "product": selectedProduct,
              "quantity": int.parse(quantityController.text),
              "price": double.parse(priceController.text),
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
      if (data.containsKey("prediction")) {
        setState(() {
          result = "Predicted Sales: ₹ ${data['prediction']}";

          history.insert(0, {
            "product": selectedProduct,
            "quantity": quantityController.text,
            "price": priceController.text,
            "result": data['prediction'].toString(),
          });
        });

        await saveHistory();

      } else {
        showError("Server Error (${response.statusCode})");
      }
      } else {
      showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      showError("Backend not reachable");
    }

    setState(() {
      isLoading = false;
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void addProduct() {
    if (productController.text.trim().isEmpty) return;

    setState(() {
      products.add(productController.text.trim());
      selectedProduct = productController.text.trim();
      productController.clear();
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text("AI Store Management"),
    ),
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E1E2C),
            Color(0xFF2D2D44),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                const SizedBox(height: 20),

                const Icon(Icons.auto_graph,
                    size: 70, color: Colors.white),

                const SizedBox(height: 10),

                const Text(
                  "AI Sales Predictor",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                /// PREDICT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: isLoading ? null : predictSales,
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : const Text(
                            "Predict Sales",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 40),

                /// RESULT CARD
                if (result.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.greenAccent, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          result,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),

                /// HISTORY SECTION
                if (history.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Prediction History",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return Container(
                        margin:
                            const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withOpacity(0.05),
                          borderRadius:
                              BorderRadius.circular(15),
                          border: Border.all(
                              color: Colors.white24),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["product"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Qty: ${item["quantity"]} | Price: ₹${item["price"]}",
                              style: const TextStyle(
                                  color: Colors.white70),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Prediction: ₹${item["result"]}",
                              style: const TextStyle(
                                  color:
                                      Colors.greenAccent),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],

                /// SALES TREND GRAPH (OUTSIDE LISTVIEW)
                if (history.isNotEmpty) ...[
                  const SizedBox(height: 40),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Sales Trend",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    height: 250,
                    padding:
                        const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.05),
                      borderRadius:
                          BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white24),
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData:
                            FlGridData(show: true),
                        borderData:
                            FlBorderData(show: true),
                        titlesData:
                            FlTitlesData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            dotData:
                                FlDotData(show: true),
                            spots: history
                                .asMap()
                                .entries
                                .map((entry) {
                              int index =
                                  entry.key;
                              double value =
                                  double.tryParse(
                                          entry.value[
                                                  "result"] ??
                                              "0") ??
                                      0;
                              return FlSpot(
                                  index.toDouble(),
                                  value);
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

              ],
            ),
          ),
        ),
      ),
    ),
  );
}
