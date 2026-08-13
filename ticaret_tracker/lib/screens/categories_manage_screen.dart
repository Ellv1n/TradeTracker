import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/storage_service.dart';
import 'category_form_screen.dart';

class CategoriesManageScreen extends StatefulWidget {
  const CategoriesManageScreen({super.key});

  @override
  State<CategoriesManageScreen> createState() => _CategoriesManageScreenState();
}

class _CategoriesManageScreenState extends State<CategoriesManageScreen> {
  final storage = StorageService();
  List<Category> categories = [];
  bool loading = true;
  bool changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await storage.loadCategories();
    c.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      categories = c;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, changed);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Kateqoriyalar')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : categories.isEmpty
                ? const Center(child: Text('Hələ kateqoriya yoxdur. + ilə əlavə edin.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: categories.length,
                    itemBuilder: (ctx, i) {
                      final c = categories[i];
                      return Card(
                        child: ListTile(
                          title: Text(c.name),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryFormScreen(category: c)));
                            changed = true;
                            _load();
                          },
                        ),
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryFormScreen()));
            changed = true;
            _load();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
