import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../utils/formatters.dart';

enum ReportPeriod { today, week, month, all }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final storage = StorageService();
  List<AppTransaction> all = [];
  bool loading = true;
  ReportPeriod period = ReportPeriod.today;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await storage.loadTransactions();
    setState(() {
      all = t;
      loading = false;
    });
  }

  List<AppTransaction> get filtered {
    final now = DateTime.now();
    DateTime from;
    switch (period) {
      case ReportPeriod.today:
        from = DateTime(now.year, now.month, now.day);
        break;
      case ReportPeriod.week:
        from = now.subtract(const Duration(days: 7));
        break;
      case ReportPeriod.month:
        from = now.subtract(const Duration(days: 30));
        break;
      case ReportPeriod.all:
        from = DateTime(2000);
        break;
    }
    return all.where((t) => t.date.isAfter(from) || t.date.isAtSameMomentAs(from)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    final txs = filtered;
    final sales = txs.where((t) => t.type == TxType.sale).toList();
    final purchases = txs.where((t) => t.type == TxType.purchase).toList();
    final salesTotal = sales.fold<double>(0, (s, t) => s + t.totalAmount);
    final purchasesTotal = purchases.fold<double>(0, (s, t) => s + t.totalAmount);
    final profit = sales.fold<double>(0, (s, t) => s + (t.unitPrice - t.costPrice) * t.quantity);

    // Kateqoriya üzrə alış xərcləri
    final Map<String, double> byCategory = {};
    for (final t in purchases) {
      final key = t.categoryName ?? 'Digər';
      byCategory[key] = (byCategory[key] ?? 0) + t.totalAmount;
    }
    final categoryEntries = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Ən çox satılan mallar
    final Map<String, double> byProduct = {};
    for (final t in sales) {
      final key = '${t.productName ?? ''}${(t.productCode ?? '').isEmpty ? '' : ' (${t.productCode})'}';
      byProduct[key] = (byProduct[key] ?? 0) + t.totalAmount;
    }
    final productEntries = byProduct.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Hesabat')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<ReportPeriod>(
              segments: const [
                ButtonSegment(value: ReportPeriod.today, label: Text('Bugün')),
                ButtonSegment(value: ReportPeriod.week, label: Text('Həftə')),
                ButtonSegment(value: ReportPeriod.month, label: Text('Ay')),
                ButtonSegment(value: ReportPeriod.all, label: Text('Hamısı')),
              ],
              selected: {period},
              onSelectionChanged: (s) => setState(() => period = s.first),
            ),
            const SizedBox(height: 16),
            _rowStat('Satış cəmi', salesTotal, Colors.blue),
            _rowStat('Alış cəmi', purchasesTotal, Colors.orange),
            _rowStat('Təxmini mənfəət', profit, profit >= 0 ? Colors.green : Colors.red),
            if (categoryEntries.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Kateqoriya üzrə alış', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...categoryEntries.map((e) => Card(
                    child: ListTile(
                      dense: true,
                      title: Text(e.key),
                      trailing: Text(formatMoney(e.value), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                    ),
                  )),
            ],
            if (productEntries.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Ən çox satılan mallar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...productEntries.take(10).map((e) => Card(
                    child: ListTile(
                      dense: true,
                      title: Text(e.key),
                      trailing: Text(formatMoney(e.value), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                  )),
            ],
            if (txs.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: Text('Bu dövrdə əməliyyat yoxdur'))),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _rowStat(String label, double value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label),
        Text(formatMoney(value), style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }
}
