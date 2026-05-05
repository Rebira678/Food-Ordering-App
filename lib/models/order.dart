import 'cart_item.dart';

enum OrderStatus { placed, preparing, delivering, delivered, cancelled }

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final double tip;
  OrderStatus status;
  final String date;
  final String restaurantName;
  final String? paymentImageUrl;
  final String? address;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.tip,
    required this.status,
    required this.date,
    required this.restaurantName,
    this.paymentImageUrl,
    this.address,
  });

  double get grandTotal => total + 2.99 + tip;

  String get statusLabel {
    switch (status) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.delivering:
        return 'Delivering';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      items: [], // Items are fetched separately usually
      total: (json['total_amount'] as num).toDouble(),
      tip: 0, // Tip not in DB schema yet, could add later
      status: _parseStatus(json['status'] as String),
      date: json['created_at'] as String,
      restaurantName: (json['restaurants'] != null) ? json['restaurants']['name'] as String : 'Unknown',
      paymentImageUrl: json['payment_image_url'] as String?,
      address: json['delivery_address'] as String?,
    );
  }

  static OrderStatus _parseStatus(String s) {
    switch (s) {
      case 'pending': return OrderStatus.placed;
      case 'preparing': return OrderStatus.preparing;
      case 'delivering': return OrderStatus.delivering;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.placed;
    }
  }
}
