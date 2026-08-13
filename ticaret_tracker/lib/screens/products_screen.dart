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
    final filtered = products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Anbar')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Mal axtar...',
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
                      ? const Center(child: Text('Mal tapılmadı. + düyməsi ilə əlavə edin.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final p = filtered[i];
                            return Card(
                              color: p.isLowStock ? Colors.orange.shade50 : Colors.white,
                              child: ListTile(
                                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text('Qalıq: ${p.quantity} ${p.unit}  •  Satış: ${formatMoney(p.salePrice)}'),
                                trailing: p.isLowStock
                                    ? const Icon(Icons.warning_amber_rounded, color: Colors.orange)
                                    : const Icon(Icons.chevron_right),
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
