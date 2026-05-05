import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';

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
          .select('*, order_items(*, menu_items(*))')
          .order('created_at', ascending: false);

      // Mapping logic would go here, for now keeping local sync
      // but inserting is the critical part for the demo.
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
