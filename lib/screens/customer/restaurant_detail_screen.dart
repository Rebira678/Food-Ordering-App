import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/menu_item_card.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final restaurant = context.read<RestaurantProvider>().findById(widget.restaurantId);
    final cart = context.watch<CartProvider>();

    if (restaurant == null) {
      return const Scaffold(body: Center(child: Text('Restaurant not found')));
    }

    if (!_initialized) {
      _tabCtrl = TabController(length: restaurant.categories.length, vsync: this);
      _initialized = true;
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: restaurant.image,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: theme.colorScheme.surfaceVariant),
                errorWidget: (_, __, ___) => Container(
                  color: theme.colorScheme.surfaceVariant,
                  child: const Icon(Icons.restaurant, size: 64),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: theme.colorScheme.onBackground.withOpacity(0.5),
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              tabs: restaurant.categories.map((c) => Tab(text: c.name)).toList(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(restaurant.location, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _pill('⭐ ${restaurant.rating}', theme),
                      _pill('🕐 ${restaurant.time}', theme),
                      _pill('🛵 ETB ${restaurant.deliveryFee.toStringAsFixed(0)}', theme),
                    ],
                  ),
                  if (restaurant.offer != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(children: [
                        const Text('🎁', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(restaurant.offer!, style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600))),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(restaurant.description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: restaurant.categories.map((category) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: category.items.length,
              itemBuilder: (ctx, i) {
                final item = category.items[i];
                return MenuItemCard(
                  item: item,
                  onAdd: () {
                    cart.addItem(CartItem(
                      id: item.id,
                      name: item.name,
                      price: item.price,
                      quantity: 1,
                      image: item.image,
                      restaurantName: restaurant.name,
                      restaurantId: restaurant.id,
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('✅ ${item.name} added!'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                );
              },
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : GestureDetector(
              onTap: () => context.push('/cart'),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(8)),
                      child: Text('${cart.itemCount}', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900)),
                    ),
                    Text('View Cart', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    Text('ETB ${cart.total.toStringAsFixed(0)}', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _pill(String text, ThemeData theme) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
      );
}
