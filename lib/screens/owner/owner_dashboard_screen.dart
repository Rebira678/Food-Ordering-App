import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late TabController _tabController;

  // State
  String? _restaurantId;
  Map<String, dynamic> _restaurant = {};
  List<Map<String, dynamic>> _liveOrders = [];
  List<Map<String, dynamic>> _popularItems = [];
  List<Map<String, dynamic>> _menuCategories = [];
  bool _isLoading = true;
  double _totalRevenue = 0;
  int _totalOrders = 0;
  int _todayOrders = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _loadDashboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    final ownerId = _supabase.auth.currentUser?.id;
    if (ownerId == null) { setState(() => _isLoading = false); return; }

    // 1. Get restaurant for this owner
    final restaurant = await _supabase
        .from('restaurants')
        .select('*')
        .eq('owner_id', ownerId)
        .maybeSingle();

    if (restaurant == null) {
      setState(() { _isLoading = false; });
      return;
    }

    _restaurantId = restaurant['id'];
    _restaurant = restaurant;

    // 2. Load everything in parallel
    await Future.wait([
      _fetchOrders(),
      _fetchPopularItems(),
      _fetchMenu(),
    ]);

    // 3. Setup realtime listener
    _supabase.channel('owner_orders_${_restaurantId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'restaurant_id',
            value: _restaurantId!,
          ),
          callback: (_) {
            _fetchOrders();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('🔔 NEW ORDER RECEIVED!'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ));
            }
          },
        )
        .subscribe();

    setState(() => _isLoading = false);
  }

  Future<void> _fetchOrders() async {
    if (_restaurantId == null) return;
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();

      final allOrders = await _supabase
          .from('orders')
          .select('*, profiles(full_name)')
          .eq('restaurant_id', _restaurantId!)
          .order('created_at', ascending: false);

      double revenue = 0;
      int todayCount = 0;
      for (final o in allOrders) {
        revenue += (o['total_amount'] as num?)?.toDouble() ?? 0;
        if (o['created_at'] != null && o['created_at'].toString().compareTo(startOfDay) >= 0) {
          todayCount++;
        }
      }

      setState(() {
        _liveOrders = List<Map<String, dynamic>>.from(allOrders);
        _totalOrders = allOrders.length;
        _totalRevenue = revenue;
        _todayOrders = todayCount;
      });
    } catch (e) {
      debugPrint('Fetch orders error: $e');
    }
  }

  Future<void> _fetchPopularItems() async {
    if (_restaurantId == null) return;
    try {
      final data = await _supabase
          .from('order_items')
          .select('quantity, menu_items(name)')
          .order('quantity', ascending: false)
          .limit(5);

      // Aggregate counts per item name
      final Map<String, int> counts = {};
      for (final row in data) {
        final name = row['menu_items']?['name'] as String? ?? 'Unknown';
        counts[name] = (counts[name] ?? 0) + ((row['quantity'] as num?)?.toInt() ?? 0);
      }

      final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      setState(() {
        _popularItems = sorted.map((e) => {'name': e.key, 'sold': e.value}).toList();
      });
    } catch (e) {
      debugPrint('Popular items error: $e');
    }
  }

  Future<void> _fetchMenu() async {
    if (_restaurantId == null) return;
    try {
      final data = await _supabase
          .from('menu_categories')
          .select('*, menu_items(*)')
          .eq('restaurant_id', _restaurantId!)
          .order('sort_order');
      setState(() => _menuCategories = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('Menu error: $e');
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await _supabase.from('orders').update({'status': status}).eq('id', orderId);
      _fetchOrders();
    } catch (e) {
      debugPrint('Update order error: $e');
    }
  }

  void _showAddFoodDialog() {
    if (_menuCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No menu categories exist!')));
      return;
    }
    
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedCategory = _menuCategories.first['id'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSB) {
          return AlertDialog(
            title: const Text('Add Menu Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Food Name')),
                  const SizedBox(height: 10),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                  const SizedBox(height: 10),
                  TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price (ETB)'), keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: _menuCategories.map((cat) => DropdownMenuItem(
                      value: cat['id'] as String,
                      child: Text(cat['name']),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setStateSB(() => selectedCategory = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
                  try {
                    await _supabase.from('menu_items').insert({
                      'id': 'i${DateTime.now().millisecondsSinceEpoch}',
                      'category_id': selectedCategory,
                      'name': nameCtrl.text.trim(),
                      'description': descCtrl.text.trim(),
                      'price': double.tryParse(priceCtrl.text) ?? 0.0,
                      'is_available': true,
                    });
                    Navigator.pop(ctx);
                    _fetchMenu();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Item added!')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showEditPriceDialog(Map<String, dynamic> item) {
    final priceCtrl = TextEditingController(text: item['price'].toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Price: ${item['name']}'),
        content: TextField(
          controller: priceCtrl,
          decoration: const InputDecoration(labelText: 'New Price (ETB)'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (priceCtrl.text.isEmpty) return;
              try {
                final newPrice = double.tryParse(priceCtrl.text) ?? 0.0;
                await _supabase.from('menu_items').update({'price': newPrice}).eq('id', item['id']);
                Navigator.pop(ctx);
                _fetchMenu();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Price updated!')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.read<AuthProvider>();

    return Scaffold(
      floatingActionButton: _tabController.index == 1 ? FloatingActionButton.extended(
        onPressed: _showAddFoodDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Food', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ) : null,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _restaurantId == null
                ? _buildNoRestaurant(theme)
                : Column(children: [
                    _buildHeader(theme, auth),
                    _buildStats(theme),
                    _buildTabBar(theme),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOrdersTab(theme),
                          _buildMenuTab(theme),
                          _buildAnalyticsTab(theme),
                        ],
                      ),
                    ),
                  ]),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text('🏪', style: TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_restaurant['name'] ?? 'My Restaurant',
                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w900)),
            Text(_restaurant['address'] ?? 'Adama, Ethiopia',
                style: theme.textTheme.bodySmall),
          ],
        )),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          onPressed: _loadDashboard,
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
          onPressed: () {
            auth.logout();
            context.go('/auth');
          },
        ),
      ]),
    );
  }

  Widget _buildStats(ThemeData theme) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        _statCard('📦', 'Total Orders', '$_totalOrders', AppColors.primary, theme),
        _statCard('💰', 'Revenue', 'ETB ${_totalRevenue.toStringAsFixed(0)}', AppColors.success, theme),
        _statCard('🌅', "Today's", '$_todayOrders orders', const Color(0xFFF59E0B), theme),
      ]),
    );
  }

  Widget _statCard(String icon, String label, String value, Color color, ThemeData theme) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 2),
            Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: theme.colorScheme.onBackground.withOpacity(0.5),
        indicator: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700),
        tabs: const [
          Tab(icon: Icon(Icons.receipt_long_rounded, size: 16), text: 'Orders'),
          Tab(icon: Icon(Icons.restaurant_menu_rounded, size: 16), text: 'Menu'),
          Tab(icon: Icon(Icons.bar_chart_rounded, size: 16), text: 'Analytics'),
        ],
      ),
    );
  }

  // ── Orders Tab ─────────────────────────────────────────────────────────────
  Widget _buildOrdersTab(ThemeData theme) {
    if (_liveOrders.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📭', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text('No orders yet', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          Text('Orders will appear here in real time!', style: theme.textTheme.bodySmall),
        ],
      ));
    }
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _liveOrders.length,
        itemBuilder: (ctx, i) {
          final o = _liveOrders[i];
          final status = o['status'] as String? ?? 'pending';
          final customer = (o['profiles'] as Map?)?['full_name'] ?? 'Customer';
          final amount = (o['total_amount'] as num?)?.toDouble() ?? 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: status == 'pending'
                  ? Border.all(color: AppColors.primary.withOpacity(0.4))
                  : null,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(customer, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(o['delivery_address'] ?? '', style: theme.textTheme.bodySmall),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('ETB ${amount.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w900)),
                  _statusBadge(status),
                ]),
              ]),
              if (status == 'pending') ...[
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(o['id'], 'preparing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text('Accept', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton(
                    onPressed: () => _updateOrderStatus(o['id'], 'cancelled'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(0, 36),
                    ),
                    child: const Text('Decline'),
                  )),
                ]),
              ] else if (status == 'preparing') ...[
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () => _updateOrderStatus(o['id'], 'delivering'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text('Mark as Out for Delivery', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
                )),
              ] else if (status == 'delivering') ...[
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () => _updateOrderStatus(o['id'], 'delivered'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text('Mark as Delivered ✓', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
                )),
              ],
            ]),
          );
        },
      ),
    );
  }

  // ── Menu Tab ───────────────────────────────────────────────────────────────
  Widget _buildMenuTab(ThemeData theme) {
    if (_menuCategories.isEmpty) {
      return const Center(child: Text('No menu items found.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _menuCategories.length,
      itemBuilder: (ctx, i) {
        final cat = _menuCategories[i];
        final items = (cat['menu_items'] as List?) ?? [];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(cat['name'],
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          ...items.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              if (item['image_url'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(item['image_url'], width: 56, height: 56, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(width: 56, height: 56)),
                ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                if (item['description'] != null)
                  Text(item['description'], style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('ETB ${(item['price'] as num).toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w800)),
              ])),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                    onPressed: () => _showEditPriceDialog(Map<String,dynamic>.from(item)),
                  ),
                  Switch(
                    value: item['is_available'] as bool? ?? true,
                    activeColor: AppColors.success,
                    onChanged: (val) async {
                      await _supabase.from('menu_items').update({'is_available': val}).eq('id', item['id']);
                      _fetchMenu();
                    },
                  ),
                ],
              ),
            ]),
          )),
        ]);
      },
    );
  }

  // ── Analytics Tab ──────────────────────────────────────────────────────────
  Widget _buildAnalyticsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Top Popular Items', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (_popularItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(14)),
            child: const Text('No order data yet. Popular items will show here once customers start ordering!'),
          )
        else
          ..._popularItems.asMap().entries.map((e) {
            final rank = e.key + 1;
            final item = e.value;
            final sold = item['sold'] as int;
            final maxSold = (_popularItems.first['sold'] as int).toDouble();
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: rank == 1 ? const Color(0xFFFFD700).withOpacity(0.2)
                        : rank == 2 ? Colors.grey.withOpacity(0.2)
                        : const Color(0xFFCD7F32).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text('$rank',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900,
                          color: rank == 1 ? const Color(0xFFFFD700) : rank == 2 ? Colors.grey : const Color(0xFFCD7F32)))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: maxSold > 0 ? sold / maxSold : 0,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ])),
                const SizedBox(width: 12),
                Text('$sold sold', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primary)),
              ]),
            );
          }),
        const SizedBox(height: 24),
        _summaryTile('📦', 'Total Orders', '$_totalOrders', theme),
        _summaryTile('💰', 'Total Revenue', 'ETB ${_totalRevenue.toStringAsFixed(2)}', theme),
        _summaryTile('🌅', "Today's Orders", '$_todayOrders', theme),
        _summaryTile('⭐', 'Restaurant Rating', '${_restaurant['rating'] ?? 'N/A'}', theme),
        _summaryTile('🕒', 'Avg Delivery Time', _restaurant['time'] ?? 'N/A', theme),
      ],
    );
  }

  Widget _summaryTile(String icon, String label, String value, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary)),
      ]),
    );
  }

  Widget _statusBadge(String status) {
    final color = switch (status) {
      'delivered' => AppColors.success,
      'cancelled' => Colors.red,
      'preparing' => Colors.orange,
      'delivering' => const Color(0xFF6366F1),
      _ => AppColors.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(),
          style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: color)),
    );
  }

  Widget _buildNoRestaurant(ThemeData theme) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🏪', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text('No Restaurant Assigned', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(
          'Your account is not yet linked to a restaurant.\nMake sure you signed up with your assigned email (e.g. kenbon@saffroneats.com)',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loadDashboard,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text('Retry', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            context.read<AuthProvider>().logout();
            context.go('/auth');
          },
          child: const Text('Sign Out'),
        ),
      ]),
    ));
  }
}
