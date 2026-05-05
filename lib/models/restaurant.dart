import 'menu_category.dart';

class Restaurant {
  final String id;
  final String name;
  final String location;
  final double lat;
  final double lng;
  final double rating;
  final String reviews;
  final String time;
  final double deliveryFee;
  final String image;
  final List<String> tags;
  final String description;
  final String? specialFeature;
  final String? offer;
  final List<MenuCategory> categories;

  const Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.reviews,
    required this.time,
    required this.deliveryFee,
    required this.image,
    required this.tags,
    required this.description,
    this.specialFeature,
    this.offer,
    required this.categories,
  });
}
