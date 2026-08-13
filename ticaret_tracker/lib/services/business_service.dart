import '../models/category.dart';
import '../models/product.dart';
import '../models/supplier.dart';
import '../models/transaction.dart';
import 'storage_service.dart';
import '../utils/id_generator.dart';

class BusinessService {
  final StorageService storage = StorageService();

  /// Təchizatçıdan ümumi (kateqoriya üzrə) alış - konkret mala bağlı deyil.
  Future<void> recordPurchase({
    required Category category,
    Supplier? supplier,
    required double totalAmount,
    required bool isCredit,
    double paidAmount = 0,
    String? note,
    required DateTime date,
  }) async {
    final suppliers = await storage.loadSuppliers();
    final txs = await storage.loadTransactions();

    double actualPaid = isCredit ? paidAmount : totalAmount;

    Supplier? sup;
    if (supplier != null) {
      final idx = suppliers.indexWhere((s) => s.id == supplier.id);
      if (idx != -1) {
        sup = suppliers[idx];
        final remaining = totalAmount - actualPaid;
        if (remaining > 0) {
          sup.debt += remaining;
        }
      }
    }

    final tx = AppTransaction(
      id: generateId(),
      type: TxType.purchase,
      date: date,
      categoryId: category.id,
      categoryName: category.name,
      totalAmount: totalAmount,
      supplierId: sup?.id,
      supplierName: sup?.name,
      isCredit: isCredit,
      paidAmount: actualPaid,
      note: note,
    );
    txs.add(tx);
    txs.sort((a, b) => b.date.compareTo(a.date));

    if (sup != null) await storage.saveSuppliers(suppliers);
    await storage.saveTransactions(txs);
  }

  /// Konkret maldan satış (məhsullar siyahısından seçilmiş mal üzrə).
  Future<String?> recordSale({
    required Product product,
    required double quantity,
    required double unitPrice,
    String? note,
    required DateTime date,
  }) async {
    final txs = await storage.loadTransactions();

    final tx = AppTransaction(
      id: generateId(),
      type: TxType.sale,
      date: date,
      productId: product.id,
      productName: product.name,
      productCode: product.code,
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: quantity * unitPrice,
      costPrice: product.costPrice,
      note: note,
    );
    txs.add(tx);
    txs.sort((a, b) => b.date.compareTo(a.date));

    await storage.saveTransactions(txs);
    return null;
  }

  Future<void> recordDebtPayment({
    required Supplier supplier,
    required double amount,
    String? note,
    required DateTime date,
  }) async {
    final suppliers = await storage.loadSuppliers();
    final txs = await storage.loadTransactions();

    final idx = suppliers.indexWhere((s) => s.id == supplier.id);
    if (idx == -1) return;
    suppliers[idx].debt -= amount;
    if (suppliers[idx].debt < 0) suppliers[idx].debt = 0;

    final tx = AppTransaction(
      id: generateId(),
      type: TxType.debtPayment,
      date: date,
      supplierId: supplier.id,
      supplierName: supplier.name,
      totalAmount: amount,
      note: note,
    );
    txs.add(tx);
    txs.sort((a, b) => b.date.compareTo(a.date));

    await storage.saveSuppliers(suppliers);
    await storage.saveTransactions(txs);
  }

  Future<void> deleteTransaction(AppTransaction tx) async {
    final suppliers = await storage.loadSuppliers();
    final txs = await storage.loadTransactions();

    if (tx.type == TxType.purchase) {
      if (tx.supplierId != null) {
        final sidx = suppliers.indexWhere((s) => s.id == tx.supplierId);
        if (sidx != -1) {
          final remaining = tx.totalAmount - tx.paidAmount;
          suppliers[sidx].debt -= remaining;
          if (suppliers[sidx].debt < 0) suppliers[sidx].debt = 0;
        }
      }
    } else if (tx.type == TxType.debtPayment) {
      final sidx = suppliers.indexWhere((s) => s.id == tx.supplierId);
      if (sidx != -1) {
        suppliers[sidx].debt += tx.totalAmount;
      }
    }
    // sale: geri qaytarılacaq stok yoxdur, sadəcə əməliyyatı silmək kifayətdir.

    txs.removeWhere((t) => t.id == tx.id);

    await storage.saveSuppliers(suppliers);
    await storage.saveTransactions(txs);
  }
}
