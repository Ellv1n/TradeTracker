import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/supplier.dart';
import '../services/business_service.dart';
import '../services/storage_service.dart';
import '../widgets/date_picker_tile.dart';
import 'categories_manage_screen.dart';
import 'category_form_screen.dart';
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

  List<Category> categories = [];
  List<Supplier> suppliers = [];
  Category? selectedCategory;
  Supplier? selectedSupplier;
  DateTime date = DateTime.now();
  bool loading = true;
  bool isCredit = false;
  bool saving = false;

  final amountCtrl = TextEditingController();
  final paidCtrl = TextEditingController(text: '0');
  final noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await storage.loadCategories();
    final s = await storage.loadSuppliers();
    c.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      categories = c;
      suppliers = s;
      selectedSupplier = widget.preselectedSupplier;
      loading = false;
    });
  }

  Future<void> _addNewCategory() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryFormScreen()));
    final c = await storage.loadCategories();
    c.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      categories = c;
      selectedCategory = c.isNotEmpty ? c.last : null;
    });
  }

  Future<void> _manageCategories() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesManageScreen()));
    final c = await storage.loadCategories();
    c.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      categories = c;
      if (selectedCategory != null && !c.any((x) => x.id == selectedCategory!.id)) {
        selectedCategory = null;
      }
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
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kateqoriya seçin')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (isCredit && selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nisyə üçün təchizatçı seçin')));
      return;
    }
    setState(() => saving = true);
    await business.recordPurchase(
      category: selectedCategory!,
      supplier: selectedSupplier,
      totalAmount: double.parse(amountCtrl.text),
      isCredit: isCredit,
      paidAmount: double.tryParse(paidCtrl.text) ?? 0,
      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      date: date,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Alış'),
        actions: [
          IconButton(
            tooltip: 'Kateqoriyaları idarə et',
            onPressed: _manageCategories,
            icon: const Icon(Icons.category_outlined),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<Category>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Kateqoriya', border: OutlineInputBorder()),
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => selectedCategory = v),
              hint: const Text('Məs: Dəftərxana'),
            ),
            TextButton.icon(onPressed: _addNewCategory, icon: const Icon(Icons.add, size: 18), label: const Text('Yeni kateqoriya əlavə et')),
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
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: 'Ümumi məbləğ', suffixText: '₼', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || double.tryParse(v) == null || double.parse(v) <= 0) ? 'Düzgün məbləğ daxil edin' : null,
            ),
            const SizedBox(height: 12),
            DatePickerTile(date: date, onChanged: (d) => setState(() => date = d)),
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
