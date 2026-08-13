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
  late TextEditingController codeCtrl;
  late TextEditingController costCtrl;
  late TextEditingController saleCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    nameCtrl = TextEditingController(text: p?.name ?? '');
    codeCtrl = TextEditingController(text: p?.code ?? '');
    costCtrl = TextEditingController(text: p != null ? _fmt(p.costPrice) : '');
    saleCtrl = TextEditingController(text: p != null ? _fmt(p.salePrice) : '');
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final products = await storage.loadProducts();
    if (widget.product == null) {
      final newProduct = Product(
        id: generateId(),
        name: nameCtrl.text.trim(),
        code: codeCtrl.text.trim(),
        costPrice: double.tryParse(costCtrl.text) ?? 0,
        salePrice: double.tryParse(saleCtrl.text) ?? 0,
      );
      products.add(newProduct);
    } else {
      final idx = products.indexWhere((p) => p.id == widget.product!.id);
      products[idx]
        ..name = nameCtrl.text.trim()
        ..code = codeCtrl.text.trim()
        ..costPrice = double.tryParse(costCtrl.text) ?? 0
        ..salePrice = double.tryParse(saleCtrl.text) ?? 0;
    }
    await storage.saveProducts(products);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silinsin?'),
        content: Text('${widget.product!.name} siyahıdan silinsin?'),
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
    if (mounted) Navigator.pop(context, true);
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
              controller: codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Kod (SKU)',
                hintText: 'Məs: DFT-001',
                helperText: 'Malı tez tapmaq üçün istənilən kodu yaza bilərsiniz',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: costCtrl,
              decoration: const InputDecoration(labelText: 'Maya qiyməti (alış dəyəri)', suffixText: '₼', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || double.tryParse(v) == null) ? 'Rəqəm daxil edin' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: saleCtrl,
              decoration: const InputDecoration(labelText: 'Satış qiyməti', suffixText: '₼', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || double.tryParse(v) == null) ? 'Rəqəm daxil edin' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Padding(padding: EdgeInsets.all(12), child: Text('Yadda saxla'))),
          ],
        ),
      ),
    );
  }
}
