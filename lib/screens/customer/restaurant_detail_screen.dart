import 'package:flutter/foundation.dart' show kIsWeb;
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
  int _activeCategory = 0;

  void _addToCart(BuildContext context, dynamic item, dynamic restaurant) {
    final cart = context.read<CartProvider>();
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
      content: Text('${item.name} added to cart'),
      backgroundColor: AppColors.success,
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = context.read<RestaurantProvider>().findById(widget.restaurantId);
    final cart = context.watch<CartProvider>();

    if (restaurant == null) {
      return const Scaffold(body: Center(child: Text('Restaurant not found')));
    }

    if (!_initialized) {
      _tabCtrl = TabController(length: restaurant.categories.length, vsync: this);
      _initialized = true;
    }

    final isWideWeb = kIsWeb && MediaQuery.of(context).size.width >= 900;
    return isWideWeb
        ? _buildWebLayout(context, restaurant, cart)
        : _buildMobileLayout(context, restaurant, cart);
  }

  // ── WEB LAYOUT ─────────────────────────────────────────────────────────────
  Widget _buildWebLayout(BuildContext context, dynamic restaurant, dynamic cart) {
    final theme = Theme.of(context);
    final categories = restaurant.categories as List;
    final activeItems = categories.isNotEmpty ? categories[_activeCategory].items as List : [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Top nav bar ──
            Container(
              height: 64,
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: Row(children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(9)),
                        child: const Center(child: Icon(Icons.restaurant_rounded, color: Colors.white, size: 18)),
                      ),
                      const SizedBox(width: 10),
                      Text('SaffronEats',
                          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ]),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Back to restaurants'),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  if (cart.itemCount > 0)
                    ElevatedButton.icon(
                      onPressed: () => context.push('/cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                      label: Text('View Cart (${cart.itemCount})  •  ETB ${cart.total.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),

            // ── Hero image ──
            Container(
              width: double.infinity,
              height: 360,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: restaurant.image as String,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: const Color(0xFF1A1D27)),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFF1A1D27),
                      child: const Icon(Icons.restaurant, size: 80, color: Colors.white24),
                    ),
                  ),
                  // Dark overlay for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Restaurant info overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1280),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(48, 0, 48, 36),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(restaurant.name as String,
                                        style: GoogleFonts.outfit(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        )),
                                    const SizedBox(height: 6),
                                    Text(restaurant.description as String,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 15, height: 1.5)),
                                    const SizedBox(height: 16),
                                    Wrap(spacing: 10, runSpacing: 8, children: [
                                      _heroBadge(Icons.star_rounded, '${restaurant.rating}', Colors.amber),
                                      _heroBadge(Icons.access_time_rounded, restaurant.time as String, Colors.white70),
                                      _heroBadge(Icons.delivery_dining_rounded, 'ETB ${(restaurant.deliveryFee as double).toStringAsFixed(0)} delivery', Colors.white70),
                                      _heroBadge(Icons.location_on_rounded, restaurant.location as String, Colors.white70),
                                    ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            // ── Main content: sidebar + menu ──
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Left sidebar: category navigation ──
                      Container(
                        width: 220,
                        margin: const EdgeInsets.only(right: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MENU CATEGORIES',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                    color: Colors.grey)),
                            const SizedBox(height: 16),
                            ...categories.asMap().entries.map((e) {
                              final isActive = _activeCategory == e.key;
                              return GestureDetector(
                                onTap: () => setState(() => _activeCategory = e.key),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isActive ? AppColors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.restaurant_menu_rounded,
                                          size: 16,
                                          color: isActive ? Colors.white : Colors.grey),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(e.value.name as String,
                                            style: GoogleFonts.outfit(
                                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                              color: isActive ? Colors.white : Colors.grey,
                                              fontSize: 14,
                                            )),
                                      ),
                                      Text('${(e.value.items as List).length}',
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: isActive ? Colors.white70 : Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                              );
                            }),

                            const SizedBox(height: 32),
                            // Cart summary box
                            if (cart.itemCount > 0)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Your Order',
                                        style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary)),
                                    const SizedBox(height: 8),
                                    Text('${cart.itemCount} item${cart.itemCount > 1 ? "s" : ""}',
                                        style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text('ETB ${cart.total.toStringAsFixed(0)}',
                                        style: GoogleFonts.outfit(
                                            fontSize: 20, fontWeight: FontWeight.w900,
                                            color: AppColors.primary)),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => context.push('/cart'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        child: Text('Go to Checkout',
                                            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // ── Right: menu items grid ──
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categories.isNotEmpty ? categories[_activeCategory].name as String : '',
                              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text('${activeItems.length} item${activeItems.length != 1 ? "s" : ""}',
                                style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 24),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                mainAxisExtent: 260,
                              ),
                              itemCount: activeItems.length,
                              itemBuilder: (ctx, i) {
                                final item = activeItems[i];
                                return _WebMenuCard(
                                  item: item,
                                  onAdd: () => _addToCart(context, item, restaurant),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Footer ──
            Container(
              color: const Color(0xFF0F1117),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
              child: Center(
                child: Text('© 2025/2026 SaffronEats — Adama, Ethiopia',
                    style: GoogleFonts.inter(color: Colors.white24, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // ── MOBILE LAYOUT (unchanged) ───────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, dynamic restaurant, dynamic cart) {
    final theme = Theme.of(context);
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
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: restaurant.image as String,
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
              tabs: (restaurant.categories as List).map((c) => Tab(text: c.name as String)).toList(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(restaurant.name as String, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(restaurant.location as String, style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: [
                  _pill('⭐ ${restaurant.rating}', theme),
                  _pill('🕐 ${restaurant.time}', theme),
                  _pill('🛵 ETB ${(restaurant.deliveryFee as double).toStringAsFixed(0)}', theme),
                ]),
                const SizedBox(height: 12),
                Text(restaurant.description as String, style: theme.textTheme.bodyMedium),
              ]),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: (restaurant.categories as List).map((category) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: (category.items as List).length,
              itemBuilder: (ctx, i) {
                final item = (category.items as List)[i];
                return MenuItemCard(
                  item: item,
                  onAdd: () => _addToCart(context, item, restaurant),
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

// ── Web Menu Card ──────────────────────────────────────────────────────────────
class _WebMenuCard extends StatefulWidget {
  final dynamic item;
  final VoidCallback onAdd;
  const _WebMenuCard({required this.item, required this.onAdd});

  @override
  State<_WebMenuCard> createState() => _WebMenuCardState();
}

class _WebMenuCardState extends State<_WebMenuCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _hovered ? AppColors.primary.withOpacity(0.15) : Colors.black.withOpacity(0.06),
              blurRadius: _hovered ? 20 : 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _hovered ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: widget.item.image as String,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: const Color(0xFF1A1D27)),
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFF1A1D27),
                    child: const Icon(Icons.fastfood_rounded, color: Colors.white24, size: 40),
                  ),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item.name as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ETB ${(widget.item.price as double).toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                      GestureDetector(
                        onTap: widget.onAdd,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _hovered ? AppColors.primary : AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.add_rounded,
                              size: 18,
                              color: _hovered ? Colors.white : AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.06);
  }
}
