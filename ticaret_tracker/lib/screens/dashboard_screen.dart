import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/supplier.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../utils/formatters.dart';
import '../widgets/stat_card.dart';
import 'debt_payment_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onChanged;
  const DashboardScreen({super.key, required this.onChanged});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final storage = StorageService();
  List<Product> products = [];
  List<Supplier> suppliers = [];
  List<AppTransaction> transactions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await storage.loadProducts();
    final s = await storage.loadSuppliers();
    final t = await storage.loadTransactions();
    setState(() {
      products = p;
      suppliers = s;
      transactions = t;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    final totalDebt = suppliers.fold<double>(0, (sum, s) => sum + s.debt);
    final now = DateTime.now();
    bool isToday(DateTime d) => d.year == now.year && d.month == now.month && d.day == now.day;

    final todaySalesTotal = transactions
        .where((t) => t.type == TxType.sale && isToday(t.date))
        .fold<double>(0, (sum, t) => sum + t.totalAmount);
    final todayPurchaseTotal = transactions
        .where((t) => t.type == TxType.purchase && isToday(t.date))
        .fold<double>(0, (sum, t) => sum + t.totalAmount);
    final debtors = suppliers.where((s) => s.debt > 0).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Ticarətim'),
            floating: true,
            backgroundColor: Color(0xFFF6F7F5),
            foregroundColor: Colors.black87,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Təchizatçılara borc',
                        value: formatMoney(totalDebt),
                        color: Colors.red,
                        icon: Icons.account_balance_wallet,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Bugünkü satış',
                        value: formatMoney(todaySalesTotal),
                        color: Colors.green,
                        icon: Icons.trending_up,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Bugünkü alış',
                        value: formatMoney(todayPurchaseTotal),
                        color: Colors.orange,
                        icon: Icons.shopping_cart,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Mal sayı',
                        value: '${products.length}',
                        color: Colors.blueGrey,
                        icon: Icons.inventory_2,
                      ),
                    ),
                  ],
                ),
                if (debtors.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Borclu olduğumuz təchizatçılar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...debtors.take(5).map((s) => Card(
                        child: ListTile(
                          title: Text(s.name),
                          trailing: Text(formatMoney(s.debt), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => DebtPaymentScreen(supplier: s)));
                            widget.onChanged();
                            _load();
                          },
                        ),
                      )),
                ],
                const SizedBox(height: 20),
                const Text('Son əməliyyatlar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                if (transactions.isEmpty)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('Hələ heç bir əməliyyat yoxdur')),
                ...transactions.take(10).map(_txTile),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _txTile(AppTransaction t) {
    IconData icon;
    Color color;
    String title;
    switch (t.type) {
      case TxType.purchase:
        icon = Icons.shopping_cart;
        color = Colors.orange;
        title = 'Alış: ${t.categoryName ?? ''}';
        break;
      case TxType.sale:
        icon = Icons.point_of_sale;
        color = Colors.blue;
        title = 'Satış: ${t.productName ?? ''}';
        break;
      case TxType.debtPayment:
        icon = Icons.payments;
        color = Colors.purple;
        title = 'Borc ödəniş: ${t.supplierName ?? ''}';
        break;
    }
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color, size: 20)),
        title: Text(title),
        subtitle: Text(formatDateTime(t.date)),
        trailing: Text(formatMoney(t.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
