import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/storage_service.dart';
import '../utils/id_generator.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final storage = StorageService();

  late TextEditingController nameCtrl;
  late TextEditingController unitCtrl;
  late TextEditingController qtyCtrl;
  late TextEditingController purchaseCtrl;
  late TextEditingController saleCtrl;
  late TextEditingController minStockCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    nameCtrl = TextEditingController(text: p?.name ?? '');
    unitCtrl = TextEditingController(text: p?.unit ?? 'ədəd');
    qtyCtrl = TextEditingController(text: p != null ? _fmt(p.quantity) : '0');
    purchaseCtrl = TextEditingController(text: p != null ? _fmt(p.purchasePrice) : '');
    saleCtrl = TextEditingController(text: p != null ? _fmt(p.salePrice) : '');
    minStockCtrl = TextEditingController(text: p != null ? _fmt(p.minStockLevel) : '0');
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final products = await storage.loadProducts();
    if (widget.product == null) {
      final newProduct = Product(
        id: generateId(),
        name: nameCtrl.text.trim(),
        unit: unitCtrl.text.trim().isEmpty ? 'ədəd' : unitCtrl.text.trim(),
        quantity: double.tryParse(qtyCtrl.text) ?? 0,
        purchasePrice: double.tryParse(purchaseCtrl.text) ?? 0,
        salePrice: double.tryParse(saleCtrl.text) ?? 0,
        minStockLevel: double.tryParse(minStockCtrl.text) ?? 0,
      );
      products.add(newProduct);
    } else {
      final idx = products.indexWhere((p) => p.id == widget.product!.id);
      products[idx]
        ..name = nameCtrl.text.trim()
        ..unit = unitCtrl.text.trim().isEmpty ? 'ədəd' : unitCtrl.text.trim()
        ..quantity = double.tryParse(qtyCtrl.text) ?? 0
        ..purchasePrice = double.tryParse(purchaseCtrl.text) ?? 0
        ..salePrice = double.tryParse(saleCtrl.text) ?? 0
        ..minStockLevel = double.tryParse(minStockCtrl.text) ?? 0;
    }
    await storage.saveProducts(products);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silinsin?'),
        content: Text('${widget.product!.name} anbardan silinsin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İmtina')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    final products = await storage.loadProducts();
    products.removeWhere((p) => p.id == widget.product!.id);
    await storage.saveProducts(products);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Malı redaktə et' : 'Yeni mal'),
        actions: [
          if (isEdit) IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Malın adı', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ad daxil edin' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: unitCtrl,
              decoration: const InputDecoration(labelText: 'Ölçü vahidi (ədəd, kg, litr...)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: qtyCtrl,
              decoration: const InputDecoration(labelText: 'Anbar qalığı', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: purchaseCtrl,
              decoration: const InputDecoration(labelText: 'Alış qiyməti (vahid üçün)', suffixText: '₼', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || double.tryParse(v) == null) ? 'Rəqəm daxil edin' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: saleCtrl,
              decoration: const InputDecoration(labelText: 'Satış qiyməti (vahid üçün)', suffixText: '₼', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || double.tryParse(v) == null) ? 'Rəqəm daxil edin' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: minStockCtrl,
              decoration: const InputDecoration(labelText: 'Minimum stok həddi (xəbərdarlıq üçün)', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Padding(padding: EdgeInsets.all(12), child: Text('Yadda saxla'))),
          ],
        ),
      ),
    );
  }
}
