import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/storage_service.dart';
import '../utils/id_generator.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;
  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final storage = StorageService();
  late TextEditingController nameCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.category?.name ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final categories = await storage.loadCategories();
    if (widget.category == null) {
      categories.add(Category(id: generateId(), name: nameCtrl.text.trim()));
    } else {
      final idx = categories.indexWhere((c) => c.id == widget.category!.id);
      categories[idx].name = nameCtrl.text.trim();
    }
    await storage.saveCategories(categories);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silinsin?'),
        content: Text('${widget.category!.name} kateqoriyası silinsin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İmtina')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    final categories = await storage.loadCategories();
    categories.removeWhere((c) => c.id == widget.category!.id);
    await storage.saveCategories(categories);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Kateqoriyanı redaktə et' : 'Yeni kateqoriya'),
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
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Kateqoriya adı',
                hintText: 'Məs: Dəftərxana, Ərzaq, Elektronika...',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ad daxil edin' : null,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Padding(padding: EdgeInsets.all(12), child: Text('Yadda saxla'))),
          ],
        ),
      ),
    );
  }
}
