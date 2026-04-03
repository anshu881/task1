import 'customer_type.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.moq,
    required this.dealerPrice,
    required this.retailPrice,
  });

  final int id;
  final String name;
  final int moq;
  final double dealerPrice;
  final double retailPrice;

  double unitPrice(CustomerType type) => switch (type) {
        CustomerType.dealer => dealerPrice,
        CustomerType.retail => retailPrice,
      };

  double totalFor(CustomerType type, int quantity) =>
      unitPrice(type) * quantity;
}
