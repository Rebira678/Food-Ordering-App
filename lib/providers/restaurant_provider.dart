import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../core/services/supabase_service.dart';

class RestaurantProvider extends ChangeNotifier {
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;

  List<Restaurant> get restaurants => List.unmodifiable(_restaurants);
  bool get isLoading => _isLoading;

  RestaurantProvider() {
    fetchLiveRestaurants();
  }

  Future<void> fetchLiveRestaurants() async {
    _isLoading = true;
    notifyListeners();
    try {
      _restaurants = await SupabaseService.fetchRestaurants();
    } catch (e) {
      debugPrint('Error fetching restaurants: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addRestaurant(Restaurant restaurant) {
    _restaurants.insert(0, restaurant);
    notifyListeners();
  }

  Restaurant? findById(String id) {
    try {
      return _restaurants.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
