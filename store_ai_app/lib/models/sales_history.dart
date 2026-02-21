class SalesHistory {
  final String product;
  final String quantity;
  final String price;
  final String result;

  SalesHistory({
    required this.product,
    required this.quantity,
    required this.price,
    required this.result,
  });

  Map<String, String> toMap() {
    return {
      "product": product,
      "quantity": quantity,
      "price": price,
      "result": result,
    };
  }

  factory SalesHistory.fromMap(Map<String, dynamic> map) {
    return SalesHistory(
      product: map['product'],
      quantity: map['quantity'],
      price: map['price'],
      result: map['result'],
    );
  }
}