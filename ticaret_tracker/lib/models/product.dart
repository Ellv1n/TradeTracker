class Product {
  String id;
  String name;
  String code;
  double costPrice;
  double salePrice;

  Product({
    required this.id,
    required this.name,
    this.code = '',
    required this.costPrice,
    required this.salePrice,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'costPrice': costPrice,
        'salePrice': salePrice,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        code: json['code'] ?? '',
        costPrice: (json['costPrice'] ?? 0).toDouble(),
        salePrice: (json['salePrice'] ?? 0).toDouble(),
      );
}
