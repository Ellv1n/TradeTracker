import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/supplier.dart';
import '../services/business_service.dart';
import '../services/storage_service.dart';
import 'product_form_screen.dart';
import 'supplier_form_screen.dart';

class PurchaseFormScreen extends StatefulWidget {
  final Supplier? preselectedSupplier;
  const PurchaseFormScreen({super.key, this.preselectedSupplier});

  @override
  State<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends State<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final storage = StorageService();
  final business = BusinessService();

  List<Product> products = [];
  List<Supplier> suppliers = [];
  Product? selectedProduct;
  Supplier? selectedSupplier;
  bool loading = true;
  bool isCredit = false;
  bool saving = false;

  final qtyCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final paidCtrl = TextEditingController(text: '0');
  final noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await storage.loadProducts();
    final s = await storage.loadSuppliers();
    p.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      products = p;
      suppliers = s;
      selectedSupplier = widget.preselectedSupplier;
      loading = false;
    });
  }

  double get total => (double.tryParse(qtyCtrl.text) ?? 0) * (double.tryParse(priceCtrl.text) ?? 0);

  Future<void> _addNewProduct() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormScreen()));
    final p = await storage.loadProducts();
    p.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      products = p;
      selectedProduct = p.isNotEmpty ? p.last : null;
    });
  }

  Future<void> _addNewSupplier() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierFormScreen()));
    final s = await storage.loadSuppliers();
    setState(() {
      suppliers = s;
      selectedSupplier = s.isNotEmpty ? s.last : null;
    });
  }

  Future<void> _save() async {
    if (selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mal seçin')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (isCredit && selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nisyə üçün təchizatçı seçin')));
      return;
    }
    setState(() => saving = true);
    await business.recordPurchase(
      product: selectedProduct!,
      supplier: selectedSupplier,
      quantity: double.parse(qtyCtrl.text),
      unitPrice: double.parse(priceCtrl.text),
      isCredit: isCredit,
      paidAmount: double.tryParse(paidCtrl.text) ?? 0,
      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Alış')),
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
                  if (v != null && v.purchasePrice > 0) priceCtrl.text = v.purchasePrice.toString();
                });
              },
            ),
            TextButton.icon(onPressed: _addNewProduct, icon: const Icon(Icons.add, size: 18), label: const Text('Yeni mal əlavə et')),
            const SizedBox(height: 12),
            DropdownButtonFormField<Supplier>(
              value: selectedSupplier,
              decoration: const InputDecoration(labelText: 'Təchizatçı (istəyə bağlı)', border: OutlineInputBorder()),
              items: suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
              onChanged: (v) => setState(() => selectedSupplier = v),
            ),
            TextButton.icon(onPressed: _addNewSupplier, icon: const Icon(Icons.add, size: 18), label: const Text('Yeni təchizatçı əlavə et')),
            const SizedBox(height: 12),
            TextFormField(
              controller: qtyCtrl,
              decoration: const InputDecoration(labelText: 'Miqdar', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || double.tryParse(v) == null || double.parse(v) <= 0) ? 'Düzgün miqdar daxil edin' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Vahid qiyməti', suffixText: '₼', border: OutlineInputBorder()),
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
            SwitchListTile(
              value: isCredit,
              onChanged: (v) => setState(() => isCredit = v),
              title: const Text('Nisyə alış'),
              subtitle: const Text('Təchizatçıya borc olaraq qeyd olunsun'),
              contentPadding: EdgeInsets.zero,
            ),
            if (isCredit) ...[
              TextFormField(
                controller: paidCtrl,
                decoration: const InputDecoration(labelText: 'İlkin ödənilən məbləğ (əgər varsa)', suffixText: '₼', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Qeyd (istəyə bağlı)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: saving ? null : _save,
              child: Padding(padding: const EdgeInsets.all(12), child: Text(saving ? 'Yadda saxlanılır...' : 'Alışı qeyd et')),
            ),
          ],
        ),
      ),
    );
  }
}
