import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

/// Fetches products from a public dummy API; falls back to bundled JSON if the request fails.
class ProductApiService {
  ProductApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _apiUrl = 'https://dummyjson.com/products?limit=20';

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client.get(
        Uri.parse(_apiUrl),
        headers: const {'User-Agent': 'task1-internal-demo/1.0'},
      );
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final list = decoded['products'] as List<dynamic>? ?? [];
      return list.map((e) => _fromDummyJson(e as Map<String, dynamic>)).toList();
    } catch (e, st) {
      debugPrint('Product API failed, using local JSON: $e\n$st');
      return _loadLocalProducts();
    }
  }

  Product _fromDummyJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final title = (json['title'] as String?)?.trim() ?? 'Product $id';
    final base = (json['price'] as num?)?.toDouble() ?? 0;
    final moq = 1 + (id % 5);
    final retail = base <= 0 ? 9.99 : base;
    final dealer = retail * 0.82;
    return Product(
      id: id,
      name: title,
      moq: moq,
      dealerPrice: double.parse(dealer.toStringAsFixed(2)),
      retailPrice: double.parse(retail.toStringAsFixed(2)),
    );
  }

  Future<List<Product>> _loadLocalProducts() async {
    final raw = await rootBundle.loadString('assets/data/products.json');
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => _fromLocalJson(e as Map<String, dynamic>))
        .toList();
  }

  Product _fromLocalJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      moq: json['moq'] as int,
      dealerPrice: (json['dealerPrice'] as num).toDouble(),
      retailPrice: (json['retailPrice'] as num).toDouble(),
    );
  }
}
