import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../utils/formatters.dart';
import 'debt_payment_screen.dart';
import 'purchase_form_screen.dart';
import 'supplier_form_screen.dart';

class SupplierDetailScreen extends StatefulWidget {
  final Supplier supplier;
  const SupplierDetailScreen({super.key, required this.supplier});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  final storage = StorageService();
  Supplier? supplier;
  List<AppTransaction> txs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final suppliers = await storage.loadSuppliers();
    final all = await storage.loadTransactions();
    final s = suppliers.firstWhere((x) => x.id == widget.supplier.id, orElse: () => widget.supplier);
    setState(() {
      supplier = s;
      txs = all.where((t) => t.supplierId == s.id).toList();
      loading = false;
    });
  }

  Future<void> _deleteSupplier() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silinsin?'),
        content: Text('${supplier!.name} təchizatçı siyahısından silinsin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İmtina')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    final suppliers = await storage.loadSuppliers();
    suppliers.removeWhere((s) => s.id == supplier!.id);
    await storage.saveSuppliers(suppliers);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final s = supplier!;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => SupplierFormScreen(supplier: s)));
              _load();
            },
          ),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: _deleteSupplier),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: s.debt > 0 ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                const Text('Cari borc', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                Text(formatMoney(s.debt), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: s.debt > 0 ? Colors.red : Colors.green)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Yeni alış'),
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => PurchaseFormScreen(preselectedSupplier: s)));
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.payments),
                    label: const Text('Borc ödə'),
                    onPressed: s.debt <= 0
                        ? null
                        : () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => DebtPaymentScreen(supplier: s)));
                            _load();
                          },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Align(alignment: Alignment.centerLeft, child: Text('Əməliyyat tarixçəsi', style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          Expanded(
            child: txs.isEmpty
                ? const Center(child: Text('Bu təchizatçı ilə əməliyyat yoxdur'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: txs.length,
                    itemBuilder: (ctx, i) {
                      final t = txs[i];
                      final isPurchase = t.type == TxType.purchase;
                      return Card(
                        child: ListTile(
                          leading: Icon(isPurchase ? Icons.shopping_cart : Icons.payments, color: isPurchase ? Colors.green : Colors.purple),
                          title: Text(isPurchase ? 'Alış: ${t.productName ?? ''}' : 'Borc ödənişi'),
                          subtitle: Text(formatDateTime(t.date) + (isPurchase && t.isCredit ? ' • Nisyə' : '')),
                          trailing: Text(formatMoney(t.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
