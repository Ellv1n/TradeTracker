class Product {
  String id;
  String name;
  String unit;
  double quantity;
  double purchasePrice;
  double salePrice;
  double minStockLevel;
  String? supplierId;

  Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.purchasePrice,
    required this.salePrice,
    this.minStockLevel = 0,
    this.supplierId,
  });

  bool get isLowStock => quantity <= minStockLevel;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        'quantity': quantity,
        'purchasePrice': purchasePrice,
        'salePrice': salePrice,
        'minStockLevel': minStockLevel,
        'supplierId': supplierId,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        unit: json['unit'] ?? 'ədəd',
        quantity: (json['quantity'] ?? 0).toDouble(),
        purchasePrice: (json['purchasePrice'] ?? 0).toDouble(),
        salePrice: (json['salePrice'] ?? 0).toDouble(),
        minStockLevel: (json['minStockLevel'] ?? 0).toDouble(),
        supplierId: json['supplierId'],
      );
}
