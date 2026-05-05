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
  bool _isRefreshing = false;

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
          onRefresh: () async {
            setState(() => _isRefreshing = true);
            await Future.delayed(const Duration(milliseconds: 800));
            setState(() => _isRefreshing = false);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
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
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(0.5),
                                      letterSpacing: 1)),
                              Row(
                                children: [
                                  Text('Adama, Ethiopia',
                                      style: GoogleFonts.outfit(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary)),
                                  const Icon(Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.primary),
                                ],
                              ),
                            ],
                          ),
                          const CartIconBadge(),
                        ],
                      ).animate().fadeIn(),

                      const SizedBox(height: 20),

                      // Search bar
                      TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                            color: theme.colorScheme.onBackground),
                        decoration: InputDecoration(
                          hintText: 'Search restaurants or cuisines...',
                          prefixIcon: Icon(Icons.search_rounded,
                              color: theme.colorScheme.onBackground
                                  .withOpacity(0.4)),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() {});
                                  })
                              : null,
                        ),
                      ).animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 20),

                      // Category filters
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
                                _activeFilter = _activeFilter == cat['name']
                                    ? null
                                    : cat['name'];
                              }),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 24),

                      Text(
                        'Explore Delicious Options Near You',
                        style: theme.textTheme.titleLarge,
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Restaurant list
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: isLoading
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),
                      )
                    : filtered.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Column(
                                  children: [
                                    const Text('😔', style: TextStyle(fontSize: 48)),
                                    const SizedBox(height: 16),
                                    Text('No restaurants match your search.',
                                        style: TextStyle(
                                            color: theme.colorScheme.onBackground
                                                .withOpacity(0.5))),
                                  ],
                                ),
                              ),
                            ),
                          )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => RestaurantCard(
                            restaurant: filtered[i],
                            onTap: () =>
                                context.push('/restaurant/${filtered[i].id}'),
                          ),
                          childCount: filtered.length,
                        ),
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
