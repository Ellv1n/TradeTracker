import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../services/storage_service.dart';
import '../utils/formatters.dart';
import 'supplier_detail_screen.dart';
import 'supplier_form_screen.dart';

enum DebtFilter { all, debtors, clear }

class DebtsScreen extends StatefulWidget {
  final VoidCallback onChanged;
  const DebtsScreen({super.key, required this.onChanged});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  final storage = StorageService();
  List<Supplier> suppliers = [];
  bool loading = true;
  DebtFilter filter = DebtFilter.all;
  String query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await storage.loadSuppliers();
    s.sort((a, b) => b.debt.compareTo(a.debt));
    setState(() {
      suppliers = s;
      loading = false;
    });
  }

  List<Supplier> get filtered {
    var list = suppliers;
    switch (filter) {
      case DebtFilter.debtors:
        list = list.where((s) => s.debt > 0).toList();
        break;
      case DebtFilter.clear:
        list = list.where((s) => s.debt <= 0).toList();
        break;
      case DebtFilter.all:
        break;
    }
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((s) => s.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final totalDebt = suppliers.fold<double>(0, (sum, s) => sum + s.debt);
    final list = filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Borclarım')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text('Ümumi borcum', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 6),
                  Text(formatMoney(totalDebt), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Təchizatçı axtar...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (v) => setState(() => query = v),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<DebtFilter>(
                segments: const [
                  ButtonSegment(value: DebtFilter.all, label: Text('Hamısı')),
                  ButtonSegment(value: DebtFilter.debtors, label: Text('Borclu')),
                  ButtonSegment(value: DebtFilter.clear, label: Text('Borcsuz')),
                ],
                selected: {filter},
                onSelectionChanged: (s) => setState(() => filter = s.first),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: list.isEmpty
                  ? const Center(child: Text('Bu filtrə uyğun təchizatçı tapılmadı'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: list.length,
                      itemBuilder: (ctx, i) {
                        final s = list[i];
                        return Card(
                          child: ListTile(
                            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(s.phone.isEmpty ? 'Telefon qeyd olunmayıb' : s.phone),
                            trailing: Text(
                              s.debt > 0 ? formatMoney(s.debt) : 'Borc yoxdur',
                              style: TextStyle(color: s.debt > 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                            ),
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => SupplierDetailScreen(supplier: s)));
                              widget.onChanged();
                              _load();
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierFormScreen()));
          widget.onChanged();
          _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
