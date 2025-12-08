import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aneuso_app/presentation/providers/admin_product_provider.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  late AdminProductProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<AdminProductProvider>(context, listen: false);
    provider.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Products')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/admin/product/form');
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<AdminProductProvider>(
        builder: (context, p, _) {
          if (p.isLoading) return const Center(child: CircularProgressIndicator());
          if (p.error != null) return Center(child: Text(p.error!));
          if (p.products.isEmpty) return const Center(child: Text('No products'));

          return ListView.separated(
            itemCount: p.products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              final prod = p.products[idx];
              return ListTile(
                title: Text(prod.productName),
                subtitle: Text('Stock: ${prod.stockQuantity}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'edit') {
                      Navigator.pushNamed(context, '/admin/product/form', arguments: {'id': prod.id});
                    } else if (v == 'delete') {
                      final ok = await p.deleteProduct(prod.id);
                      if (!ok) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete failed')));
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
