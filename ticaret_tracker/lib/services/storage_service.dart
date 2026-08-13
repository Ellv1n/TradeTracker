import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/supplier.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class StorageService {
  static const _productsKey = 'products';
  static const _suppliersKey = 'suppliers';
  static const _transactionsKey = 'transactions';
  static const _categoriesKey = 'categories';

  Future<List<Product>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_productsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Product.fromJson(e)).toList();
  }

  Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_productsKey, jsonEncode(products.map((e) => e.toJson()).toList()));
  }

  Future<List<Supplier>> loadSuppliers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_suppliersKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Supplier.fromJson(e)).toList();
  }

  Future<void> saveSuppliers(List<Supplier> suppliers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_suppliersKey, jsonEncode(suppliers.map((e) => e.toJson()).toList()));
  }

  Future<List<AppTransaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_transactionsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    final txs = list.map((e) => AppTransaction.fromJson(e)).toList();
    txs.sort((a, b) => b.date.compareTo(a.date));
    return txs;
  }

  Future<void> saveTransactions(List<AppTransaction> txs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_transactionsKey, jsonEncode(txs.map((e) => e.toJson()).toList()));
  }

  Future<List<Category>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_categoriesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Category.fromJson(e)).toList();
  }

  Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_categoriesKey, jsonEncode(categories.map((e) => e.toJson()).toList()));
  }
}
