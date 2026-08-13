enum TxType { purchase, sale, debtPayment }

TxType txTypeFromString(String s) {
  switch (s) {
    case 'purchase':
      return TxType.purchase;
    case 'sale':
      return TxType.sale;
    case 'debtPayment':
      return TxType.debtPayment;
  }
  return TxType.purchase;
}

class AppTransaction {
  String id;
  TxType type;
  DateTime date;
  String? productId;
  String? productName;
  double quantity;
  double unitPrice;
  double totalAmount;
  double costPrice; // yalnız satış üçün - satış anındakı maya dəyəri
  String? supplierId;
  String? supplierName;
  bool isCredit;
  double paidAmount;
  String? note;

  AppTransaction({
    required this.id,
    required this.type,
    required this.date,
    this.productId,
    this.productName,
    this.quantity = 0,
    this.unitPrice = 0,
    this.totalAmount = 0,
    this.costPrice = 0,
    this.supplierId,
    this.supplierName,
    this.isCredit = false,
    this.paidAmount = 0,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString().split('.').last,
        'date': date.toIso8601String(),
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalAmount': totalAmount,
        'costPrice': costPrice,
        'supplierId': supplierId,
        'supplierName': supplierName,
        'isCredit': isCredit,
        'paidAmount': paidAmount,
        'note': note,
      };

  factory AppTransaction.fromJson(Map<String, dynamic> json) => AppTransaction(
        id: json['id'],
        type: txTypeFromString(json['type']),
        date: DateTime.parse(json['date']),
        productId: json['productId'],
        productName: json['productName'],
        quantity: (json['quantity'] ?? 0).toDouble(),
        unitPrice: (json['unitPrice'] ?? 0).toDouble(),
        totalAmount: (json['totalAmount'] ?? 0).toDouble(),
        costPrice: (json['costPrice'] ?? 0).toDouble(),
        supplierId: json['supplierId'],
        supplierName: json['supplierName'],
        isCredit: json['isCredit'] ?? false,
        paidAmount: (json['paidAmount'] ?? 0).toDouble(),
        note: json['note'],
      );
}
