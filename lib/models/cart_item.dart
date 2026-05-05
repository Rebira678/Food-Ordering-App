class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String image;
  final String restaurantName;
  final String restaurantId;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.restaurantName,
    required this.restaurantId,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'image': image,
        'restaurantName': restaurantName,
        'restaurantId': restaurantId,
      };
}
