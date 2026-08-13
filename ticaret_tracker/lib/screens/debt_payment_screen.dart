import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../services/business_service.dart';
import '../utils/formatters.dart';

class DebtPaymentScreen extends StatefulWidget {
  final Supplier supplier;
  const DebtPaymentScreen({super.key, required this.supplier});

  @override
  State<DebtPaymentScreen> createState() => _DebtPaymentScreenState();
}

class _DebtPaymentScreenState extends State<DebtPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final business = BusinessService();
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  bool saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => saving = true);
    await business.recordDebtPayment(
      supplier: widget.supplier,
      amount: double.parse(amountCtrl.text),
      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.supplier.name} - Borc ödəniş')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Cari borc'),
                Text(formatMoney(widget.supplier.debt), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: 'Ödənilən məbləğ', suffixText: '₼', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || double.tryParse(v) == null || double.parse(v) <= 0) return 'Düzgün məbləğ daxil edin';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Qeyd (istəyə bağlı)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: saving ? null : _save,
              child: Padding(padding: const EdgeInsets.all(12), child: Text(saving ? 'Yadda saxlanılır...' : 'Ödənişi qeyd et')),
            ),
          ],
        ),
      ),
    );
  }
}
