class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String restaurantId;
  final String restaurantName;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.restaurantId,
    required this.restaurantName,
  });
}
