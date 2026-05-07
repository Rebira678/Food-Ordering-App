import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('orders')
          .select('*, restaurants(name), order_items(*, menu_items(name, image_url))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<Order> loadedOrders = [];
      for (final row in response) {
        final orderItemsData = row['order_items'] as List<dynamic>? ?? [];
        final items = orderItemsData.map<CartItem>((item) {
          final menuItem = item['menu_items'];
          return CartItem(
            id: item['menu_item_id']?.toString() ?? '',
            name: menuItem != null ? (menuItem['name'] ?? 'Unknown') : 'Unknown',
            price: (item['unit_price'] as num?)?.toDouble() ?? 0.0,
            quantity: item['quantity'] as int? ?? 1,
            image: menuItem != null ? (menuItem['image_url'] ?? '') : '',
            restaurantName: row['restaurants'] != null ? (row['restaurants']['name'] ?? 'Unknown') : 'Unknown',
            restaurantId: row['restaurant_id']?.toString() ?? '',
          );
        }).toList();

        final orderInfo = Order.fromJson(row);
        loadedOrders.add(Order(
          id: orderInfo.id,
          items: items,
          total: orderInfo.total,
          tip: orderInfo.tip,
          status: orderInfo.status,
          date: orderInfo.date,
          restaurantName: orderInfo.restaurantName,
          paymentImageUrl: orderInfo.paymentImageUrl,
          address: orderInfo.address,
        ));
      }
      
      _orders = loadedOrders;
      _setupRealtime(userId);
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupRealtime(String userId) {
    _supabase.channel('customer_orders_$userId')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'orders',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
        callback: (payload) {
          // Instead of manually updating, just refetch to get all relationships correctly
          fetchOrders();
        },
      )
      .subscribe();
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _supabase.from('orders').update({'status': newStatus}).eq('id', orderId);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index].status = Order.parseStatus(newStatus);
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  Future<bool> addOrder(Order order, String restaurantId, {String? address}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      // 1. Insert Order
      final orderRes = await _supabase.from('orders').insert({
        'user_id': userId,
        'restaurant_id': restaurantId,
        'status': 'pending',
        'total_amount': order.total + (order.tip ?? 0),
        'delivery_address': address ?? order.address ?? 'Local Address',
        'payment_image_url': order.paymentImageUrl,
      }).select().single();

      final orderId = orderRes['id'];

      // 2. Insert Order Items
      final itemsToInsert = order.items.map((item) => {
        'order_id': orderId,
        'menu_item_id': item.id,
        'quantity': item.quantity,
        'unit_price': item.price,
      }).toList();

      await _supabase.from('order_items').insert(itemsToInsert);

      _orders.insert(0, order);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ ERROR PLACING ORDER: $e');
      return false;
    }
  }
}
