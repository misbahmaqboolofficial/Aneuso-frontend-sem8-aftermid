import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aneuso_app/presentation/providers/admin_product_provider.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
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
      appBar: AppBar(title: const Text('Products')),
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
                subtitle: Text(prod.description ?? ''),
                trailing: Text('Rs ${prod.price ?? 0}'),
                onTap: () {
                  // open product detail or admin edit in future
                },
              );
            },
          );
        },
      ),
    );
  }
}
