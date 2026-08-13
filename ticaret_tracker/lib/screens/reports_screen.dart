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
    return all.where((t) => t.date.isAfter(from)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    final txs = filtered;
    final sales = txs.where((t) => t.type == TxType.sale);
    final purchases = txs.where((t) => t.type == TxType.purchase);
    final salesTotal = sales.fold<double>(0, (s, t) => s + t.totalAmount);
    final purchasesTotal = purchases.fold<double>(0, (s, t) => s + t.totalAmount);
    final profit = sales.fold<double>(0, (s, t) => s + (t.unitPrice - t.costPrice) * t.quantity);

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
            const SizedBox(height: 20),
            Text('Əməliyyatlar (${txs.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            if (txs.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('Bu dövrdə əməliyyat yoxdur')),
            ...txs.map((t) => Card(
                  child: ListTile(
                    title: Text(_title(t)),
                    subtitle: Text(formatDateTime(t.date)),
                    trailing: Text(formatMoney(t.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _title(AppTransaction t) {
    switch (t.type) {
      case TxType.purchase:
        return 'Alış: ${t.productName ?? ''}';
      case TxType.sale:
        return 'Satış: ${t.productName ?? ''}';
      case TxType.debtPayment:
        return 'Borc ödənişi: ${t.supplierName ?? ''}';
    }
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
