import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/order_list.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/order.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  Future<void> _refreshOrders(BuildContext context) {
    return Provider.of<OrderList>(
      context,
      listen: false,
    ).loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Meus Pedidos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshOrders(context),
        child: FutureBuilder(
          future: Provider.of<OrderList>(
            context,
            listen: false,
          ).loadOrders(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.error != null) {
              return const Center(
                child: Text('Ocorreu um erro!'),
              );
            } else {
              return Consumer<OrderList>(
                builder: (ctx, orders, child) => ListView.builder(
                  itemCount: orders.itemsCount,
                  itemBuilder: (ctx, i) => OrderWidget(order: orders.items[i]),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
