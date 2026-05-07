import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/restaurant_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/cart_icon_badge.dart';
import '../../widgets/category_filter_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String? _activeFilter;

  static const _categories = [
    {'id': '1', 'name': 'Meat', 'icon': '🥩'},
    {'id': '2', 'name': 'Fast Food', 'icon': '🍔'},
    {'id': '3', 'name': 'Meals', 'icon': '🍲'},
    {'id': '4', 'name': 'Traditional', 'icon': '🫕'},
    {'id': '5', 'name': 'Grill', 'icon': '🔥'},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideWeb = kIsWeb && MediaQuery.of(context).size.width >= 768;
    return isWideWeb ? _buildWebLayout(context) : _buildMobileLayout(context);
  }

  // ── WEB LAYOUT ─────────────────────────────────────────────────────────────
  Widget _buildWebLayout(BuildContext context) {
    final theme = Theme.of(context);
    final restaurantProv = context.watch<RestaurantProvider>();
    final restaurants = restaurantProv.restaurants;
    final isLoading = restaurantProv.isLoading;
    final query = _searchCtrl.text.toLowerCase();
    final width = MediaQuery.of(context).size.width;

    final filtered = restaurants.where((r) {
      final matchesSearch = query.isEmpty ||
          r.name.toLowerCase().contains(query) ||
          r.tags.any((t) => t.toLowerCase().contains(query));
      final matchesFilter = _activeFilter == null ||
          r.tags.any((t) => t.toLowerCase() == _activeFilter!.toLowerCase());
      return matchesSearch && matchesFilter;
    }).toList();

    final crossAxisCount = width > 1200 ? 3 : 2;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── HERO BANNER ──
            Container(
              width: double.infinity,
              height: 420,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F1117), Color(0xFF1A2610)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(top: -60, right: -60,
                    child: Container(width: 300, height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(bottom: -80, left: -40,
                    child: Container(width: 260, height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.06),
                      ),
                    ),
                  ),
                  // Hero content centered
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Row(
                          children: [
                            // Text side
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text('🚀  Fast Delivery in Adama',
                                        style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                                  ),
                                  const SizedBox(height: 20),
                                  Text('Order Delicious Food\nRight to Your Door',
                                      style: GoogleFonts.outfit(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.15,
                                      )),
                                  const SizedBox(height: 16),
                                  Text('Explore the best local restaurants in Adama.\nFresh food, fast delivery, fair prices.',
                                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 16, height: 1.6)),
                                  const SizedBox(height: 32),
                                  // Search bar in hero
                                  Container(
                                    constraints: const BoxConstraints(maxWidth: 480),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8))],
                                    ),
                                    child: TextField(
                                      controller: _searchCtrl,
                                      onChanged: (_) => setState(() {}),
                                      style: const TextStyle(color: Color(0xFF0F1117), fontSize: 15),
                                      decoration: InputDecoration(
                                        hintText: 'Search restaurants or cuisines...',
                                        hintStyle: const TextStyle(color: Colors.grey),
                                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                                        suffixIcon: _searchCtrl.text.isNotEmpty
                                            ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () { _searchCtrl.clear(); setState(() {}); })
                                            : null,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.05),
                            ),
                            const SizedBox(width: 48),
                            // Decorative food emoji side
                            Expanded(
                              child: Center(
                                child: Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary.withOpacity(0.12),
                                  ),
                                  child: const Center(
                                    child: Text('🍽️', style: TextStyle(fontSize: 120)),
                                  ),
                                ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── STATS ROW ──
            Container(
              color: theme.cardColor,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem('🍴', '${restaurants.length}+', 'Restaurants'),
                        _statDivider(),
                        _statItem('⚡', '25–45 min', 'Avg Delivery'),
                        _statDivider(),
                        _statItem('🌟', '4.7', 'Avg Rating'),
                        _statDivider(),
                        _statItem('🛵', 'ETB 15–30', 'Delivery Fee'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── CATEGORY FILTERS ──
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(48, 40, 48, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filter by Cuisine',
                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Colors.grey)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _categories.map((cat) => CategoryFilterChip(
                          icon: cat['icon']!,
                          label: cat['name']!,
                          isActive: _activeFilter == cat['name'],
                          onTap: () => setState(() {
                            _activeFilter = _activeFilter == cat['name'] ? null : cat['name'];
                          }),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── RESTAURANTS SECTION ──
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(48, 0, 48, 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Explore Delicious Options Near You',
                                  style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: theme.colorScheme.onBackground)),
                              const SizedBox(height: 4),
                              Text(
                                filtered.isEmpty ? 'No restaurants match your search' : '${filtered.length} restaurant${filtered.length != 1 ? "s" : ""} available',
                                style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                          if (_activeFilter != null)
                            TextButton.icon(
                              onPressed: () => setState(() => _activeFilter = null),
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              label: const Text('Clear filter'),
                              style: TextButton.styleFrom(foregroundColor: Colors.grey),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (isLoading)
                        const Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ))
                      else if (filtered.isEmpty)
                        Center(child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 80),
                          child: Column(children: [
                            const Text('😔', style: TextStyle(fontSize: 56)),
                            const SizedBox(height: 16),
                            Text('No restaurants match your search.',
                                style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)),
                          ]),
                        ))
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 24,
                            mainAxisExtent: 320,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) => RestaurantCard(
                            restaurant: filtered[i],
                            onTap: () => context.push('/restaurant/${filtered[i].id}'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── FOOTER ──
            Container(
              color: const Color(0xFF0F1117),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('SaffronEats', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          const Spacer(),
                          Text('© 2025/2026 SaffronEats — Adama, Ethiopia',
                              style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  Widget _statDivider() => Container(width: 1, height: 50, color: Colors.grey.withOpacity(0.2));

  // ── MOBILE LAYOUT (unchanged) ───────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    final restaurantProv = context.watch<RestaurantProvider>();
    final restaurants = restaurantProv.restaurants;
    final isLoading = restaurantProv.isLoading;
    final query = _searchCtrl.text.toLowerCase();

    final filtered = restaurants.where((r) {
      final matchesSearch = query.isEmpty ||
          r.name.toLowerCase().contains(query) ||
          r.tags.any((t) => t.toLowerCase().contains(query));
      final matchesFilter = _activeFilter == null ||
          r.tags.any((t) => t.toLowerCase() == _activeFilter!.toLowerCase());
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Delivering to',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                                      letterSpacing: 1)),
                              Row(
                                children: [
                                  Text('Adama, Ethiopia',
                                      style: GoogleFonts.outfit(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary)),
                                  const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                                ],
                              ),
                            ],
                          ),
                          const CartIconBadge(),
                        ],
                      ).animate().fadeIn(),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(color: theme.colorScheme.onBackground),
                        decoration: InputDecoration(
                          hintText: 'Search restaurants or cuisines...',
                          prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.onBackground.withOpacity(0.4)),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () { _searchCtrl.clear(); setState(() {}); })
                              : null,
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (ctx, i) {
                            final cat = _categories[i];
                            return CategoryFilterChip(
                              icon: cat['icon']!,
                              label: cat['name']!,
                              isActive: _activeFilter == cat['name'],
                              onTap: () => setState(() {
                                _activeFilter = _activeFilter == cat['name'] ? null : cat['name'];
                              }),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 24),
                      Text('Explore Delicious Options Near You', style: theme.textTheme.titleLarge).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: isLoading
                    ? const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.only(top: 40), child: CircularProgressIndicator(color: AppColors.primary))))
                    : filtered.isEmpty
                        ? SliverToBoxAdapter(child: Center(child: Padding(padding: const EdgeInsets.only(top: 40), child: Column(children: [
                            const Text('😔', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            Text('No restaurants match your search.', style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.5))),
                          ]))))
                        : SliverList(delegate: SliverChildBuilderDelegate(
                            (ctx, i) => RestaurantCard(restaurant: filtered[i], onTap: () => context.push('/restaurant/${filtered[i].id}')),
                            childCount: filtered.length,
                          )),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
