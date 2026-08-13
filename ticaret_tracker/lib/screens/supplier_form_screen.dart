import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../services/storage_service.dart';
import '../utils/id_generator.dart';

class SupplierFormScreen extends StatefulWidget {
  final Supplier? supplier;
  const SupplierFormScreen({super.key, this.supplier});

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final storage = StorageService();
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController noteCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.supplier?.name ?? '');
    phoneCtrl = TextEditingController(text: widget.supplier?.phone ?? '');
    noteCtrl = TextEditingController(text: widget.supplier?.note ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final suppliers = await storage.loadSuppliers();
    if (widget.supplier == null) {
      suppliers.add(Supplier(id: generateId(), name: nameCtrl.text.trim(), phone: phoneCtrl.text.trim(), note: noteCtrl.text.trim()));
    } else {
      final idx = suppliers.indexWhere((s) => s.id == widget.supplier!.id);
      suppliers[idx]
        ..name = nameCtrl.text.trim()
        ..phone = phoneCtrl.text.trim()
        ..note = noteCtrl.text.trim();
    }
    await storage.saveSuppliers(suppliers);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.supplier == null ? 'Yeni təchizatçı' : 'Təchizatçını redaktə et')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Ad / Firma adı', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ad daxil edin' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Telefon', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Qeyd (istəyə bağlı)', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Padding(padding: EdgeInsets.all(12), child: Text('Yadda saxla'))),
          ],
        ),
      ),
    );
  }
}
