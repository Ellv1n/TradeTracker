class Supplier {
  String id;
  String name;
  String phone;
  String? note;
  double debt;

  Supplier({
    required this.id,
    required this.name,
    this.phone = '',
    this.note,
    this.debt = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'note': note,
        'debt': debt,
      };

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json['id'],
        name: json['name'],
        phone: json['phone'] ?? '',
        note: json['note'],
        debt: (json['debt'] ?? 0).toDouble(),
      );
}
