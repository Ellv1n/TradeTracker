import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/business_service.dart';
import '../services/storage_service.dart';

class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({super.key});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final storage = StorageService();
  final business = BusinessService();

  List<Product> products = [];
  Product? selectedProduct;
  bool loading = true;
  bool saving = false;

  final qtyCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

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

  double get total => (double.tryParse(qtyCtrl.text) ?? 0) * (double.tryParse(priceCtrl.text) ?? 0);

  Future<void> _save() async {
    if (selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mal seçin')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => saving = true);
    final error = await business.recordSale(
      product: selectedProduct!,
      quantity: double.parse(qtyCtrl.text),
      unitPrice: double.parse(priceCtrl.text),
      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
    );
    if (error != null) {
      setState(() => saving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (products.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yeni Satış')),
        body: const Center(child: Text('Əvvəlcə anbara mal əlavə edin')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Satış')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<Product>(
              value: selectedProduct,
              decoration: const InputDecoration(labelText: 'Mal', border: OutlineInputBorder()),
              items: products.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (qalıq: ${p.quantity} ${p.unit})'))).toList(),
              onChanged: (v) {
                setState(() {
                  selectedProduct = v;
                  if (v != null) priceCtrl.text = v.salePrice.toString();
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: qtyCtrl,
              decoration: const InputDecoration(labelText: 'Miqdar', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || double.tryParse(v) == null || double.parse(v) <= 0) return 'Düzgün miqdar daxil edin';
                if (selectedProduct != null && double.parse(v) > selectedProduct!.quantity) return 'Anbarda kifayət qədər yoxdur';
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Satış qiyməti (vahid)', suffixText: '₼', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || double.tryParse(v) == null) ? 'Düzgün qiymət daxil edin' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Ümumi məbləğ'),
                Text('${total.toStringAsFixed(2)} ₼', style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Qeyd (istəyə bağlı)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: saving ? null : _save,
              child: Padding(padding: const EdgeInsets.all(12), child: Text(saving ? 'Yadda saxlanılır...' : 'Satışı qeyd et')),
            ),
          ],
        ),
      ),
    );
  }
}
