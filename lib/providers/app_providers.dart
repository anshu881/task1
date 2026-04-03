import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer_type.dart';
import '../models/product.dart';
import '../services/product_api_service.dart';

final productApiServiceProvider = Provider<ProductApiService>((ref) {
  return ProductApiService();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final api = ref.watch(productApiServiceProvider);
  return api.fetchProducts();
});

final customerTypeProvider =
    StateProvider<CustomerType>((ref) => CustomerType.retail);
