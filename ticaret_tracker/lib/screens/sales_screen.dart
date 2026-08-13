import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/business_service.dart';
import '../services/storage_service.dart';
import '../utils/formatters.dart';

enum SalesPeriod { today, week, month, all }

class SalesScreen extends StatefulWidget {
  final VoidCallback onChanged;
  const SalesScreen({super.key, required this.onChanged});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final storage = StorageService();
  final business = BusinessService();
  List<AppTransaction> all = [];
  bool loading = true;
  SalesPeriod period = SalesPeriod.today;
  String query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await storage.loadTransactions();
    setState(() {
      all = t.where((x) => x.type == TxType.sale).toList();
      loading = false;
    });
  }

  List<AppTransaction> get filtered {
    final now = DateTime.now();
    DateTime from;
    switch (period) {
      case SalesPeriod.today:
        from = DateTime(now.year, now.month, now.day);
        break;
      case SalesPeriod.week:
        from = now.subtract(const Duration(days: 7));
        break;
      case SalesPeriod.month:
        from = now.subtract(const Duration(days: 30));
        break;
      case SalesPeriod.all:
        from = DateTime(2000);
        break;
    }
    var list = all.where((t) => t.date.isAfter(from) || t.date.isAtSameMomentAs(from)).toList();
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((t) =>
          (t.productName ?? '').toLowerCase().contains(q) || (t.productCode ?? '').toLowerCase().contains(q)).toList();
    }
    return list;
  }

  Future<void> _delete(AppTransaction t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silinsin?'),
        content: const Text('Bu satış qeydi silinsin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İmtina')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    await business.deleteTransaction(t);
    widget.onChanged();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    final txs = filtered;
    final total = txs.fold<double>(0, (s, t) => s + t.totalAmount);
    final profit = txs.fold<double>(0, (s, t) => s + (t.unitPrice - t.costPrice) * t.quantity);

    return Scaffold(
      appBar: AppBar(title: const Text('Satışlarım')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Mal adına və ya koduna görə axtar...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (v) => setState(() => query = v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<SalesPeriod>(
                segments: const [
                  ButtonSegment(value: SalesPeriod.today, label: Text('Bugün')),
                  ButtonSegment(value: SalesPeriod.week, label: Text('Həftə')),
                  ButtonSegment(value: SalesPeriod.month, label: Text('Ay')),
                  ButtonSegment(value: SalesPeriod.all, label: Text('Hamısı')),
                ],
                selected: {period},
                onSelectionChanged: (s) => setState(() => period = s.first),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(children: [
                        const Text('Cəmi satış', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text(formatMoney(total), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(children: [
                        const Text('Mənfəət', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text(formatMoney(profit), style: TextStyle(fontWeight: FontWeight.bold, color: profit >= 0 ? Colors.green : Colors.red)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: txs.isEmpty
                  ? const Center(child: Text('Bu filtrə uyğun satış tapılmadı'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: txs.length,
                      itemBuilder: (ctx, i) {
                        final t = txs[i];
                        return Dismissible(
                          key: ValueKey(t.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) async {
                            await _delete(t);
                            return false;
                          },
                          child: Card(
                            child: ListTile(
                              leading: const CircleAvatar(backgroundColor: Color(0xFFE3F2FD), child: Icon(Icons.point_of_sale, color: Colors.blue, size: 20)),
                              title: Text('${t.productName ?? ''}${(t.productCode ?? '').isEmpty ? '' : ' (${t.productCode})'}'),
                              subtitle: Text('${formatDate(t.date)} • ${t.quantity.toStringAsFixed(t.quantity == t.quantity.roundToDouble() ? 0 : 2)} ədəd x ${formatMoney(t.unitPrice)}'),
                              trailing: Text(formatMoney(t.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
