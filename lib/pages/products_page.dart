import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product_list.dart';
import 'package:shop/utils/app_routes.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/product_item.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  Future<void> _refreshProducts(BuildContext context) {
    return Provider.of<ProductList>(
      context,
      listen: false,
    ).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final ProductList products = Provider.of(context);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text(
            'Gerenciar Produtos',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.product_form,
                );
              },
            )
          ],
        ),
        drawer: const AppDrawer(),
        body: RefreshIndicator(
          onRefresh: () => _refreshProducts(context),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              itemCount: products.itemsCount,
              itemBuilder: (ctx, i) => Column(
                children: [
                  ProductItem(products.items[i]),
                  const Divider(),
                ],
              ),
            ),
          ),
        ));
  }
}
