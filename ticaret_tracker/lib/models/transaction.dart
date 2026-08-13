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

  // Alış (kateqoriya üzrə ümumi alış) sahələri
  String? categoryId;
  String? categoryName;

  // Satış (konkret mal) sahələri
  String? productId;
  String? productName;
  String? productCode;
  double quantity;
  double unitPrice;
  double costPrice; // satış anındakı maya dəyəri (mənfəət hesablamaq üçün)

  // Ümumi sahələr
  double totalAmount;
  String? supplierId;
  String? supplierName;
  bool isCredit;
  double paidAmount;
  String? note;

  AppTransaction({
    required this.id,
    required this.type,
    required this.date,
    this.categoryId,
    this.categoryName,
    this.productId,
    this.productName,
    this.productCode,
    this.quantity = 0,
    this.unitPrice = 0,
    this.costPrice = 0,
    this.totalAmount = 0,
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
        'categoryId': categoryId,
        'categoryName': categoryName,
        'productId': productId,
        'productName': productName,
        'productCode': productCode,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'costPrice': costPrice,
        'totalAmount': totalAmount,
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
        categoryId: json['categoryId'],
        categoryName: json['categoryName'],
        productId: json['productId'],
        productName: json['productName'],
        productCode: json['productCode'],
        quantity: (json['quantity'] ?? 0).toDouble(),
        unitPrice: (json['unitPrice'] ?? 0).toDouble(),
        costPrice: (json['costPrice'] ?? 0).toDouble(),
        totalAmount: (json['totalAmount'] ?? 0).toDouble(),
        supplierId: json['supplierId'],
        supplierName: json['supplierName'],
        isCredit: json['isCredit'] ?? false,
        paidAmount: (json['paidAmount'] ?? 0).toDouble(),
        note: json['note'],
      );
}
