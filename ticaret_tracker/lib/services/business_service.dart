import '../models/product.dart';
import '../models/supplier.dart';
import '../models/transaction.dart';
import 'storage_service.dart';
import '../utils/id_generator.dart';

class BusinessService {
  final StorageService storage = StorageService();

  Future<void> recordPurchase({
    required Product product,
    Supplier? supplier,
    required double quantity,
    required double unitPrice,
    required bool isCredit,
    double paidAmount = 0,
    String? note,
  }) async {
    final products = await storage.loadProducts();
    final suppliers = await storage.loadSuppliers();
    final txs = await storage.loadTransactions();

    final idx = products.indexWhere((p) => p.id == product.id);
    if (idx == -1) return;
    final p = products[idx];
    final newQty = p.quantity + quantity;
    if (newQty > 0) {
      p.purchasePrice = ((p.quantity * p.purchasePrice) + (quantity * unitPrice)) / newQty;
    }
    p.quantity = newQty;

    final totalAmount = quantity * unitPrice;
    double actualPaid = paidAmount;
    if (!isCredit) actualPaid = totalAmount;

    Supplier? sup;
    if (supplier != null) {
      final sidx = suppliers.indexWhere((s) => s.id == supplier.id);
      if (sidx != -1) {
        sup = suppliers[sidx];
        final remaining = totalAmount - actualPaid;
        if (remaining > 0) {
          sup.debt += remaining;
        }
      }
    }

    final tx = AppTransaction(
      id: generateId(),
      type: TxType.purchase,
      date: DateTime.now(),
      productId: p.id,
      productName: p.name,
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      supplierId: sup?.id,
      supplierName: sup?.name,
      isCredit: isCredit,
      paidAmount: actualPaid,
      note: note,
    );
    txs.insert(0, tx);

    await storage.saveProducts(products);
    if (sup != null) await storage.saveSuppliers(suppliers);
    await storage.saveTransactions(txs);
  }

  Future<String?> recordSale({
    required Product product,
    required double quantity,
    required double unitPrice,
    String? note,
  }) async {
    final products = await storage.loadProducts();
    final txs = await storage.loadTransactions();

    final idx = products.indexWhere((p) => p.id == product.id);
    if (idx == -1) return 'Mal tapılmadı';
    final p = products[idx];
    if (quantity > p.quantity) {
      return 'Anbarda kifayət qədər mal yoxdur (mövcud: ${p.quantity} ${p.unit})';
    }
    p.quantity -= quantity;

    final tx = AppTransaction(
      id: generateId(),
      type: TxType.sale,
      date: DateTime.now(),
      productId: p.id,
      productName: p.name,
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: quantity * unitPrice,
      costPrice: p.purchasePrice,
      note: note,
    );
    txs.insert(0, tx);

    await storage.saveProducts(products);
    await storage.saveTransactions(txs);
    return null;
  }

  Future<void> recordDebtPayment({
    required Supplier supplier,
    required double amount,
    String? note,
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
      date: DateTime.now(),
      supplierId: supplier.id,
      supplierName: supplier.name,
      totalAmount: amount,
      note: note,
    );
    txs.insert(0, tx);

    await storage.saveSuppliers(suppliers);
    await storage.saveTransactions(txs);
  }

  Future<void> deleteTransaction(AppTransaction tx) async {
    final products = await storage.loadProducts();
    final suppliers = await storage.loadSuppliers();
    final txs = await storage.loadTransactions();

    if (tx.type == TxType.purchase) {
      final pidx = products.indexWhere((p) => p.id == tx.productId);
      if (pidx != -1) {
        products[pidx].quantity -= tx.quantity;
        if (products[pidx].quantity < 0) products[pidx].quantity = 0;
      }
      if (tx.supplierId != null) {
        final sidx = suppliers.indexWhere((s) => s.id == tx.supplierId);
        if (sidx != -1) {
          final remaining = tx.totalAmount - tx.paidAmount;
          suppliers[sidx].debt -= remaining;
          if (suppliers[sidx].debt < 0) suppliers[sidx].debt = 0;
        }
      }
    } else if (tx.type == TxType.sale) {
      final pidx = products.indexWhere((p) => p.id == tx.productId);
      if (pidx != -1) {
        products[pidx].quantity += tx.quantity;
      }
    } else if (tx.type == TxType.debtPayment) {
      final sidx = suppliers.indexWhere((s) => s.id == tx.supplierId);
      if (sidx != -1) {
        suppliers[sidx].debt += tx.totalAmount;
      }
    }

    txs.removeWhere((t) => t.id == tx.id);

    await storage.saveProducts(products);
    await storage.saveSuppliers(suppliers);
    await storage.saveTransactions(txs);
  }
}
