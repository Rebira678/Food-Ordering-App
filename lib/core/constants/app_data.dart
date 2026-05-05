import '../../models/restaurant.dart';
import '../../models/menu_item.dart';
import '../../models/menu_category.dart';

/// Same data as frontend/constants/Data.ts, converted to Dart
const List<Map<String, dynamic>> kRestaurantsRaw = [
  {
    'id': 1,
    'name': 'Kenbon Restaurant',
    'location': 'Downtown Adama',
    'lat': 8.5414,
    'lng': 39.2689,
    'rating': 4.8,
    'reviews': '2.4k',
    'time': '25-35 min',
    'deliveryFee': 25.0,
    'image':
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=400&q=80',
    'tags': ['Fast Food', 'Burgers', 'Pizzas'],
    'description':
        'KenBon Restaurant brings you the authentic taste of both traditional and modern recipes in the heart of Adama. Enjoy a sophisticated ambiance with exceptional service.',
    'specialFeature':
        'Live acoustic music on weekends and 100% organic locally sourced ingredients.',
    'offer': '10% off for first-time orders using referral discounts!',
    'categories': [
      {
        'name': 'Juice',
        'items': [
          {
            'id': 101,
            'name': 'Sprite/Coca-Cola',
            'description': 'Refreshing cold soda',
            'price': 30.0,
            'image':
                'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=200&q=80',
          },
          {
            'id': 102,
            'name': 'Fresh Mango Juice',
            'description': 'Freshly squeezed seasonal mangoes',
            'price': 65.0,
            'image':
                'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
      {
        'name': 'Fast Food',
        'items': [
          {
            'id': 103,
            'name': 'Egg Sandwich',
            'description': 'Toasted bread with fluffy scrambled eggs',
            'price': 120.0,
            'image':
                'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
      {
        'name': 'Meat',
        'items': [
          {
            'id': 105,
            'name': 'Tibs (Beef/Goat)',
            'description': 'Sizzling Ethiopian stir-fried meat with rosemary',
            'price': 400.0,
            'image':
                'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=200&q=80',
          },
          {
            'id': 106,
            'name': 'Double Patty Burger',
            'description': 'Two 100% beef patties with melting cheese',
            'price': 350.0,
            'image':
                'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
      {
        'name': 'Meals',
        'items': [
          {
            'id': 107,
            'name': 'Special Mixed Salad',
            'description': 'Fresh local greens with a house vinaigrette',
            'price': 150.0,
            'image':
                'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
    ],
  },
  {
    'id': 2,
    'name': 'YegnawBet Restaurant',
    'location': 'Bole Adama Zone',
    'lat': 8.5470,
    'lng': 39.2710,
    'rating': 4.9,
    'reviews': '1.8k',
    'time': '30-45 min',
    'deliveryFee': 30.0,
    'image':
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80',
    'tags': ['Meals', 'Traditional', 'Local'],
    'description':
        'YegnawBet is your home away from home. We specialize in serving up the boldest, most flavorful traditional dishes. Fast delivery and high-quality food guaranteed.',
    'specialFeature': 'Exclusive home-made spices prepared through generations.',
    'offer': 'Free delivery on all orders over 1000 ETB!',
    'categories': [
      {
        'name': 'Juice',
        'items': [
          {
            'id': 201,
            'name': 'Traditional Tej (Honey Wine)',
            'description': 'Locally fermented honey beverage',
            'price': 200.0,
            'image':
                'https://images.unsplash.com/photo-1587843063065-4f4debaae9a5?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
      {
        'name': 'Fast Food',
        'items': [
          {
            'id': 202,
            'name': 'Chechebsa',
            'description': 'Torn pieces of flatbread cooked in spiced butter',
            'price': 150.0,
            'image':
                'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
      {
        'name': 'Meat',
        'items': [
          {
            'id': 203,
            'name': 'Doro Wat',
            'description': 'Spicy chicken stew with boiled eggs',
            'price': 600.0,
            'image':
                'https://images.unsplash.com/photo-1585937421612-70a008356fbe?auto=format&fit=crop&w=200&q=80',
          },
          {
            'id': 204,
            'name': 'Shiro Tegabino',
            'description': 'Thick chickpea stew served bubbling hot',
            'price': 250.0,
            'image':
                'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
      {
        'name': 'Meals',
        'items': [
          {
            'id': 205,
            'name': 'Veggie Combo (Tsom Beyaynetu)',
            'description': 'Various fasting dishes on injera',
            'price': 280.0,
            'image':
                'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
    ],
  },
  {
    'id': 3,
    'name': 'Gola Adama Restaurant',
    'location': 'Adama University Road',
    'lat': 8.5500,
    'lng': 39.2800,
    'rating': 4.7,
    'reviews': '500',
    'time': '15-25 min',
    'deliveryFee': 15.0,
    'image':
        'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=400&q=80',
    'tags': ['Fast Food', 'Snacks'],
    'description':
        'Gola Adama offers incredible fast food specifically catered to the fast-paced life. Hot, fresh, and irresistibly tasty cravings sorted!',
    'specialFeature': 'Fastest delivery in the university area and a 24/7 kitchen.',
    'offer': 'Buy 1 Get 1 Free on all milkshakes every Friday.',
    'categories': [
      {
        'name': 'Juice',
        'items': [
          {
            'id': 301,
            'name': 'Chocolate Milkshake',
            'description': 'Thick rich chocolate drink',
            'price': 120.0,
            'image':
                'https://images.unsplash.com/photo-1553787499-6f9133860278?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
      {
        'name': 'Fast Food',
        'items': [
          {
            'id': 302,
            'name': 'Margarita Pizza Slice',
            'description': 'Wood-fired tomato and cheese slice',
            'price': 90.0,
            'image':
                'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
      {
        'name': 'Meat',
        'items': [
          {
            'id': 303,
            'name': 'Spicy Chicken Wings',
            'description': '6 pieces of buffalo styled chicken wings',
            'price': 280.0,
            'image':
                'https://images.unsplash.com/photo-1564834724105-918b73d1b9e0?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
      {
        'name': 'Meals',
        'items': [
          {
            'id': 304,
            'name': 'French Fries',
            'description': 'Golden crispy potato fingers',
            'price': 80.0,
            'image':
                'https://images.unsplash.com/photo-1614398751058-eb2e0bf63e53?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
    ],
  },
  {
    'id': 4,
    'name': 'Marafa Restaurant',
    'location': 'Posta Bet Area',
    'lat': 8.5420,
    'lng': 39.2600,
    'rating': 4.6,
    'reviews': '3.1k',
    'time': '35-50 min',
    'deliveryFee': 20.0,
    'image':
        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=400&q=80',
    'tags': ['Grill', 'Meat'],
    'description':
        'Famous for our premium grill items, Marafa Restaurant elevates the dining experience. If you are a meat-lover, you have found your sanctuary.',
    'specialFeature':
        'Open fire grill in the center of the restaurant providing an immersive dining experience.',
    'offer': 'Family combo deals available every weekend!',
    'categories': [
      {
        'name': 'Juice',
        'items': [
          {
            'id': 401,
            'name': 'Fresh Guava Juice',
            'description': 'Sweet and thick guava drink',
            'price': 70.0,
            'image':
                'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
      {
        'name': 'Fast Food',
        'items': [
          {
            'id': 402,
            'name': 'Pasta with Tomato Sauce',
            'description': 'Al dente spaghetti with a rich Napoli base',
            'price': 200.0,
            'image':
                'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
      {
        'name': 'Meat',
        'items': [
          {
            'id': 403,
            'name': 'Half Roasted Chicken',
            'description': 'Marinated and slowly roasted over open fire',
            'price': 450.0,
            'image':
                'https://images.unsplash.com/photo-1598514982205-f36b96d1e8d4?auto=format&fit=crop&w=200&q=80',
          },
          {
            'id': 404,
            'name': 'Kurt (Raw Beef)',
            'description': 'Premium cut Ethiopian raw beef',
            'price': 700.0,
            'image':
                'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
      {
        'name': 'Meals',
        'items': [
          {
            'id': 405,
            'name': 'Garlic Bread',
            'description': 'Toasted baguette sliced with garlic butter',
            'price': 60.0,
            'image':
                'https://images.unsplash.com/photo-1626082895617-2c6ad3ed3098?auto=format&fit=crop&w=200&q=80',
          },
        ],
      },
    ],
  },
];

List<Restaurant> get kRestaurants {
  return kRestaurantsRaw.map((r) {
    final categories = (r['categories'] as List<Map<String, dynamic>>)
        .map((c) => MenuCategory(
              name: c['name'] as String,
              items: (c['items'] as List<Map<String, dynamic>>)
                  .map((item) => MenuItem(
                        id: item['id'].toString(),
                        name: item['name'] as String,
                        description: item['description'] as String,
                        price: (item['price'] as num).toDouble(),
                        image: item['image'] as String,
                        restaurantId: r['id'].toString(),
                        restaurantName: r['name'] as String,
                      ))
                  .toList(),
            ))
        .toList();

    return Restaurant(
      id: r['id'].toString(),
      name: r['name'] as String,
      location: r['location'] as String,
      lat: (r['lat'] as num).toDouble(),
      lng: (r['lng'] as num).toDouble(),
      rating: (r['rating'] as num).toDouble(),
      reviews: r['reviews'] as String,
      time: r['time'] as String,
      deliveryFee: (r['deliveryFee'] as num).toDouble(),
      image: r['image'] as String,
      tags: List<String>.from(r['tags'] as List),
      description: r['description'] as String,
      specialFeature: r['specialFeature'] as String?,
      offer: r['offer'] as String?,
      categories: categories,
    );
  }).toList();
}
