import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'products_screen.dart';
import 'sales_screen.dart';
import 'debts_screen.dart';
import 'reports_screen.dart';
import 'purchase_form_screen.dart';
import 'sale_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  int _refreshKey = 0;

  void _refreshAll() {
    setState(() => _refreshKey++);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(key: ValueKey('dash_$_refreshKey'), onChanged: _refreshAll),
      ProductsScreen(key: ValueKey('prod_$_refreshKey'), onChanged: _refreshAll),
      SalesScreen(key: ValueKey('sales_$_refreshKey'), onChanged: _refreshAll),
      DebtsScreen(key: ValueKey('debts_$_refreshKey'), onChanged: _refreshAll),
      ReportsScreen(key: ValueKey('rep_$_refreshKey')),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAdd(context),
        icon: const Icon(Icons.add),
        label: const Text('Əməliyyat'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Ana səhifə'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Mallar'),
          NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: 'Satışlar'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Borclar'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Hesabat'),
        ],
      ),
    );
  }

  void _showQuickAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFFFE9DA), child: Icon(Icons.shopping_cart, color: Colors.deepOrange)),
              title: const Text('Yeni Alış (topdan)'),
              subtitle: const Text('Kateqoriya üzrə, nisyə və ya nağd'),
              onTap: () async {
                Navigator.pop(ctx);
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseFormScreen()));
                _refreshAll();
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE3F2FD), child: Icon(Icons.point_of_sale, color: Colors.blue)),
              title: const Text('Yeni Satış'),
              subtitle: const Text('Müştəriyə mal satışı'),
              onTap: () async {
                Navigator.pop(ctx);
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const SaleFormScreen()));
                _refreshAll();
              },
            ),
          ],
        ),
      ),
    );
  }
}
