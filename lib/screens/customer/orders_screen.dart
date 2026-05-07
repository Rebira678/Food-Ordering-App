import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/order_timeline.dart';

import '../../models/order.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  String _getStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed: return 'Your order has been received by the restaurant.';
      case OrderStatus.preparing: return 'Chef is currently preparing your meal.';
      case OrderStatus.delivering: return 'Your food is on the way! Please confirm when received.';
      case OrderStatus.delivered: return 'Order has been delivered. Enjoy your meal!';
      case OrderStatus.cancelled: return 'This order was cancelled.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orders = context.watch<OrderProvider>().orders;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Text('Active Orders', style: theme.textTheme.titleLarge),
              ),
            ),
            if (orders.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      const Text('📦', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text('You have no placed orders yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.5))),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final order = orders[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.restaurantName, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              'Order #${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()} • ${order.items.length} items • ETB ${order.grandTotal.toStringAsFixed(2)}',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            // List the items ordered
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(item.name, style: const TextStyle(fontSize: 13))),
                                      Text('ETB ${item.price}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 20),
                            OrderTimeline(status: order.statusLabel),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ordered at ${order.date.split('T').first}',
                                    style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(_getStatusMessage(order.status), style: theme.textTheme.bodySmall),
                                ],
                              ),
                            ),
                            if (order.status == OrderStatus.delivering) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.read<OrderProvider>().updateOrderStatus(order.id, 'delivered');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: const Text('Confirm Received / I have eaten', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                    childCount: orders.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}
