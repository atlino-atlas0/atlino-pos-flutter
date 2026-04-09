import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  double discount; // per-item discount amount

  CartItem({
    required this.product,
    this.quantity = 1,
    this.discount = 0,
  });

  double get unitPrice => product.sellingPrice;
  double get lineTotal => (unitPrice * quantity) - discount;

  Map<String, dynamic> toSaleItem() {
    return {
      'product_id': product.id,
      'product_name': product.name,
      'barcode': product.barcode,
      'quantity': quantity,
      'unit_price': unitPrice,
      'tax_rate': product.taxRate,
      'tax_amount': 0,
      'discount': discount,
      'total_amount': lineTotal,
    };
  }
}
