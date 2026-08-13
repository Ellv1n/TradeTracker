import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/business_service.dart';
import '../widgets/date_picker_tile.dart';
import 'product_picker_screen.dart';

class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({super.key});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final business = BusinessService();

  Product? selectedProduct;
  DateTime date = DateTime.now();
  bool saving = false;

  final qtyCtrl = TextEditingController(text: '1');
  final priceCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  double get total => (double.tryParse(qtyCtrl.text) ?? 0) * (double.tryParse(priceCtrl.text) ?? 0);

  Future<void> _pickProduct() async {
    final p = await Navigator.push<Product>(context, MaterialPageRoute(builder: (_) => const ProductPickerScreen()));
    if (p != null) {
      setState(() {
        selectedProduct = p;
        priceCtrl.text = p.salePrice == p.salePrice.roundToDouble() ? p.salePrice.toStringAsFixed(0) : p.salePrice.toString();
      });
    }
  }

  Future<void> _save() async {
    if (selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mal seçin')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => saving = true);
    await business.recordSale(
      product: selectedProduct!,
      quantity: double.parse(qtyCtrl.text),
      unitPrice: double.parse(priceCtrl.text),
      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      date: date,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Satış')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InkWell(
              onTap: _pickProduct,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Mal', border: OutlineInputBorder()),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedProduct == null
                            ? 'Mal seçmək üçün toxunun'
                            : '${selectedProduct!.name}${selectedProduct!.code.isEmpty ? '' : ' (${selectedProduct!.code})'}',
                        style: TextStyle(color: selectedProduct == null ? Colors.grey.shade600 : Colors.black87),
                      ),
                    ),
                    const Icon(Icons.search, size: 20, color: Colors.black45),
                  ],
                ),
              ),
            ),
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
              decoration: const InputDecoration(labelText: 'Satış qiyməti (vahid)', suffixText: '₼', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || double.tryParse(v) == null) ? 'Düzgün qiymət daxil edin' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            DatePickerTile(date: date, onChanged: (d) => setState(() => date = d)),
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
