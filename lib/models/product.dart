class Product {
  final int id;
  final String name;
  final String? sku;
  final String? barcode;
  final String? category;
  final double mrp;
  final double sellingPrice;
  final int quantity;
  final double taxRate;
  final String? imageUrl;
  final String? color;
  final String? styleName;

  const Product({
    required this.id,
    required this.name,
    this.sku,
    this.barcode,
    this.category,
    required this.mrp,
    required this.sellingPrice,
    required this.quantity,
    this.taxRate = 0,
    this.imageUrl,
    this.color,
    this.styleName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final mrp = _parseDouble(json['mrp']) ?? 0;
    final selling = _parseDouble(json['selling_price']) ?? mrp;
    return Product(
      id: json['id'] as int,
      name: json['name'] ?? '',
      sku: json['sku'],
      barcode: json['barcode'],
      category: json['category'],
      mrp: mrp,
      sellingPrice: selling,
      quantity: (json['quantity'] ?? json['inventory_quantity'] ?? 0) as int,
      taxRate: _parseDouble(json['tax_rate'] ?? json['tax']) ?? 0,
      imageUrl: json['image_url'],
      color: json['color'],
      styleName: json['style_name'],
    );
  }

  static double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString());
  }

  String get displayCode => barcode ?? sku ?? '#$id';
}
