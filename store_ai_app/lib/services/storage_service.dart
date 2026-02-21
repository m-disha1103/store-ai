import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_model.dart';

class StorageService {
  static Future<void> saveHistory(List<SalesHistory> history) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historyList =
        history.map((item) => jsonEncode(item.toMap())).toList();
    await prefs.setStringList('sales_history', historyList);
  }

  static Future<List<SalesHistory>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? historyList = prefs.getStringList('sales_history');

    if (historyList == null) return [];

    return historyList
        .map((item) =>
            SalesHistory.fromMap(jsonDecode(item)))
        .toList();
  }
}