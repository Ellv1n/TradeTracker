import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import '../utils/formatters.dart';
import 'product_form_screen.dart';

class ProductsScreen extends StatefulWidget {
  final VoidCallback onChanged;
  const ProductsScreen({super.key, required this.onChanged});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
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
      appBar: AppBar(title: const Text('Mallarım')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
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
                          child: Text(products.isEmpty
                              ? 'Hələ mal yoxdur. + düyməsi ilə əlavə edin.'
                              : 'Nəticə tapılmadı'),
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
                                onTap: () async {
                                  await Navigator.push(context, MaterialPageRoute(builder: (_) => ProductFormScreen(product: p)));
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormScreen()));
          widget.onChanged();
          _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
