import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import '../utils/formatters.dart';
import 'product_form_screen.dart';

class ProductPickerScreen extends StatefulWidget {
  const ProductPickerScreen({super.key});

  @override
  State<ProductPickerScreen> createState() => _ProductPickerScreenState();
}

class _ProductPickerScreenState extends State<ProductPickerScreen> {
  final storage = StorageService();
  List<Product> products = [];
  String query = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await storage.loadProducts();
    p.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      products = p;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? products
        : products.where((p) => p.name.toLowerCase().contains(q) || p.code.toLowerCase().contains(q)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mal seç')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Adına və ya koduna görə axtar...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (v) => setState(() => query = v),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(products.isEmpty ? 'Hələ mal yoxdur. Əvvəlcə mal əlavə edin.' : 'Nəticə tapılmadı'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final p = filtered[i];
                            return Card(
                              child: ListTile(
                                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: p.code.isEmpty ? null : Text('Kod: ${p.code}'),
                                trailing: Text(formatMoney(p.salePrice), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                onTap: () => Navigator.pop(context, p),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormScreen()));
          _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni mal'),
      ),
    );
  }
}
