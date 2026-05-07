import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/restaurant.dart';
import '../../models/menu_category.dart';
import '../../models/menu_item.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  static Future<List<Restaurant>> fetchRestaurants() async {
    try {
      final response = await client.from('restaurants').select('''
        *,
        menu_categories (
          id,
          name,
          menu_items (*)
        )
      ''');

      return (response as List).map((r) {
        final categoriesList = r['menu_categories'] as List? ?? [];
        
        final categories = categoriesList.map((c) {
          final itemsList = c['menu_items'] as List? ?? [];
          return MenuCategory(
            name: c['name'],
            items: itemsList.map((item) => MenuItem(
              id: item['id'].toString(),
              name: item['name'],
              description: item['description'] ?? '',
              price: (item['price'] as num).toDouble(),
              image: _fixImageUrl(item['image_url']),
              restaurantId: r['id'].toString(),
              restaurantName: r['name'],
            )).toList(),
          );
        }).toList();

        return Restaurant(
          id: r['id'].toString(),
          name: r['name'],
          location: r['address'],
          lat: 0.0,
          lng: 0.0,
          rating: (r['rating'] as num?)?.toDouble() ?? 0.0,
          reviews: 'New',
          time: r['time'] ?? '30 min',
          deliveryFee: (r['delivery_fee'] as num?)?.toDouble() ?? 0.0,
          image: _fixImageUrl(r['image_url']),
          tags: List<String>.from(r['tags'] ?? []),
          description: r['description'] ?? '',
          categories: categories.cast<MenuCategory>(),
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ ERROR FETCHING RESTAURANTS: $e');
      return [];
    }
  }

  /// Append proper Unsplash params so images load on web & mobile.
  /// Falls back to a reliable food photo placeholder if URL is empty.
  static String _fixImageUrl(dynamic raw) {
    const fallback = 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80&auto=format&fit=crop';
    if (raw == null || raw.toString().isEmpty) return fallback;
    final url = raw.toString().trim();
    if (url.contains('unsplash.com') && !url.contains('?')) {
      return '$url?w=800&q=80&auto=format&fit=crop';
    }
    return url;
  }
}
