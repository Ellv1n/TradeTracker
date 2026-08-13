import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../services/storage_service.dart';
import '../utils/formatters.dart';
import 'supplier_detail_screen.dart';
import 'supplier_form_screen.dart';

class SuppliersScreen extends StatefulWidget {
  final VoidCallback onChanged;
  const SuppliersScreen({super.key, required this.onChanged});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final storage = StorageService();
  List<Supplier> suppliers = [];
  bool loading = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Təchizatçılar')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : suppliers.isEmpty
              ? const Center(child: Text('Hələ təchizatçı yoxdur. + ilə əlavə edin.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: suppliers.length,
                  itemBuilder: (ctx, i) {
                    final s = suppliers[i];
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
