import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/sales_history.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedProduct = "Product A";

  List<String> products = ["Product A"];

  List<SalesHistory> history = [];

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

  Future<void> loadHistory() async {
  final loadedHistory = await StorageService.loadHistory();
  setState(() {
    history = loadedHistory;
  });
}

  Future<void> saveHistory() async {
    await StorageService.saveHistory(history);
  }

  Future<void> predictSales() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      result = "";
    });

   final prediction = await ApiService.predictSales(
  product: selectedProduct,
  quantity: int.parse(quantityController.text),
  price: double.parse(priceController.text),
);

if (prediction != null) {
  setState(() {
    result = "Predicted Sales: ₹ $prediction";

    history.insert(
      0,
      SalesHistory(
        product: selectedProduct,
        quantity: quantityController.text,
        price: priceController.text,
        result: prediction.toString(),
      ),
    );
  });

  await saveHistory();
} else {
  showError("Server Error");
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
      appBar: AppBar(
        title: const Text("AI Store Management"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Product Dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedProduct,
              items: products
                  .map(
                    (product) => DropdownMenuItem(
                      value: product,
                      child: Text(product),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedProduct = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Select Product",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// Add New Product
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: productController,
                    decoration: const InputDecoration(
                      labelText: "Add New Product",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: addProduct,
                  child: const Text("Add"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Quantity",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter quantity" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Price",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter price" : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Predict Button
            ElevatedButton(
              onPressed: isLoading ? null : predictSales,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Predict Sales"),
            ),

            const SizedBox(height: 20),

            /// Result
            if (result.isNotEmpty)
              Text(
                result,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 20),

            /// History
            if (history.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sales History",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...history.map(
                    (item) => Card(
                      child: ListTile(
                        title: Text(item.product),
                        subtitle: Text(
                            "Qty: ${item.quantity} | Price: ₹${item.price}"),
                        trailing: Text("₹${item.result}"),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}