import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';

class SuperadminDashboardScreen extends StatefulWidget {
  const SuperadminDashboardScreen({super.key});

  @override
  State<SuperadminDashboardScreen> createState() => _SuperadminDashboardScreenState();
}

class _SuperadminDashboardScreenState extends State<SuperadminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late TabController _tabController;

  // Data
  List<Map<String, dynamic>> _restaurants = [];
  List<Map<String, dynamic>> _applications = [];
  List<Map<String, dynamic>> _recentOrders = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchStats(),
      _fetchRestaurants(),
      _fetchApplications(),
      _fetchRecentOrders(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchStats() async {
    try {
      final restaurants = await _supabase.from('restaurants').select('id');
      final orders = await _supabase.from('orders').select('total_amount');
      final users = await _supabase.from('profiles').select('id, role');
      final pending = await _supabase.from('owner_applications').select('id').eq('status', 'pending');

      double totalRevenue = 0;
      for (final o in orders) {
        totalRevenue += (o['total_amount'] as num?)?.toDouble() ?? 0;
      }

      setState(() {
        _stats = {
          'restaurants': restaurants.length,
          'orders': orders.length,
          'users': users.length,
          'revenue': totalRevenue,
          'pending_apps': pending.length,
          'customers': users.where((u) => u['role'] == 'customer').length,
          'owners': users.where((u) => u['role'] == 'owner').length,
        };
      });
    } catch (e) {
      debugPrint('Stats error: $e');
    }
  }

  Future<void> _fetchRestaurants() async {
    try {
      final data = await _supabase
          .from('restaurants')
          .select('*, profiles(full_name)')
          .order('created_at', ascending: false);
      setState(() => _restaurants = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('Restaurants error: $e');
    }
  }

  Future<void> _fetchApplications() async {
    try {
      final data = await _supabase
          .from('owner_applications')
          .select()
          .order('created_at', ascending: false);
      setState(() => _applications = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('Applications error: $e');
    }
  }

  Future<void> _fetchRecentOrders() async {
    try {
      final data = await _supabase
          .from('orders')
          .select('*, restaurants(name), profiles(full_name)')
          .order('created_at', ascending: false)
          .limit(20);
      setState(() => _recentOrders = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('Orders error: $e');
    }
  }

  Future<void> _toggleRestaurantStatus(String id, bool current) async {
    try {
      await _supabase.from('restaurants').update({'is_active': !current}).eq('id', id);
      _fetchRestaurants();
      _showSnack(!current ? '✅ Restaurant activated' : '🔴 Restaurant deactivated');
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  Future<void> _updateApplicationStatus(String id, String status) async {
    try {
      await _supabase.from('owner_applications').update({'status': status}).eq('id', id);
      _fetchApplications();
      _fetchStats();
      _showSnack(status == 'approved' ? '✅ Application approved!' : '❌ Application rejected.');
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _showAddRestaurantDialog() {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Restaurant'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Restaurant Name')),
              const SizedBox(height: 10),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
              const SizedBox(height: 10),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 10),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Owner Email (for linking)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              try {
                await _supabase.from('restaurants').insert({
                  'id': 'c${DateTime.now().millisecondsSinceEpoch}',
                  'name': nameCtrl.text.trim(),
                  'address': addressCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'owner_email': emailCtrl.text.trim().toLowerCase(),
                  'is_active': true,
                  'rating': 5.0,
                });
                Navigator.pop(ctx);
                _fetchRestaurants();
                _showSnack('✅ Restaurant added successfully!');
              } catch (e) {
                _showSnack('Error: $e');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: _tabController.index == 1 ? FloatingActionButton.extended(
        onPressed: _showAddRestaurantDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Restaurant', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ) : null,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            _buildTabBar(theme),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(theme),
                        _buildRestaurantsTab(theme),
                        _buildApplicationsTab(theme),
                        _buildOrdersTab(theme),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFFF8C42)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SaffronEats Control Panel',
                    style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primary)),
                Text('Platform Administrator', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAllData,
            color: AppColors.primary,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/auth');
            },
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: theme.colorScheme.onBackground.withOpacity(0.5),
        indicator: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 11),
        tabs: const [
          Tab(icon: Icon(Icons.dashboard_rounded, size: 18), text: 'Overview'),
          Tab(icon: Icon(Icons.store_rounded, size: 18), text: 'Restaurants'),
          Tab(icon: Icon(Icons.assignment_rounded, size: 18), text: 'Applications'),
          Tab(icon: Icon(Icons.receipt_long_rounded, size: 18), text: 'Orders'),
        ],
      ),
    );
  }

  // ─── TAB 1: OVERVIEW ──────────────────────────────────────────────────────
  Widget _buildOverviewTab(ThemeData theme) {
    final pendingApps = _stats['pending_apps'] ?? 0;
    return RefreshIndicator(
      onRefresh: _loadAllData,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stat Cards
          GridView.count(
            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _statCard('🏪', 'Restaurants', '${_stats['restaurants'] ?? 0}', AppColors.primary, theme),
              _statCard('📦', 'Total Orders', '${_stats['orders'] ?? 0}', AppColors.success, theme),
              _statCard('👥', 'Customers', '${_stats['customers'] ?? 0}', const Color(0xFF6366F1), theme),
              _statCard('💰', 'Revenue', 'ETB ${((_stats['revenue'] ?? 0.0) as double).toStringAsFixed(0)}', const Color(0xFFF59E0B), theme),
            ],
          ),
          const SizedBox(height: 16),

          // Pending Alert
          if (pendingApps > 0)
            GestureDetector(
              onTap: () => _tabController.animateTo(2),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: Row(children: [
                  const Text('⏳', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$pendingApps Pending Application${pendingApps > 1 ? 's' : ''}',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15)),
                      Text('New restaurant partners awaiting your review', style: theme.textTheme.bodySmall),
                    ],
                  )),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.amber),
                ]),
              ),
            ),
          const SizedBox(height: 16),

          // Platform Summary
          _sectionTitle('Platform Summary', theme),
          const SizedBox(height: 10),
          _summaryTile('🏪', 'Active Restaurants', '${_stats['restaurants'] ?? 0}', theme),
          _summaryTile('🧑‍🍳', 'Restaurant Owners', '${_stats['owners'] ?? 0}', theme),
          _summaryTile('🛵', 'Total Orders Placed', '${_stats['orders'] ?? 0}', theme),
          _summaryTile('👤', 'Registered Customers', '${_stats['customers'] ?? 0}', theme),
          _summaryTile('⏳', 'Pending Applications', '${_stats['pending_apps'] ?? 0}', theme),
        ],
      ),
    );
  }

  // ─── TAB 2: RESTAURANTS ───────────────────────────────────────────────────
  Widget _buildRestaurantsTab(ThemeData theme) {
    if (_restaurants.isEmpty) {
      return _emptyState('No restaurants yet.', '🏪', theme);
    }
    return RefreshIndicator(
      onRefresh: _fetchRestaurants,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _restaurants.length,
        itemBuilder: (ctx, i) {
          final r = _restaurants[i];
          final isActive = r['is_active'] as bool? ?? true;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? AppColors.success.withOpacity(0.3) : Colors.red.withOpacity(0.2),
              ),
            ),
            child: Column(children: [
              // Image header
              if (r['image_url'] != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    r['image_url'],
                    height: 140, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Center(child: Text('🏪', style: TextStyle(fontSize: 40))),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(r['name'] ?? 'Unknown',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isActive ? AppColors.success : Colors.red).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(isActive ? 'ACTIVE' : 'INACTIVE',
                            style: GoogleFonts.outfit(
                              fontSize: 10, fontWeight: FontWeight.w900,
                              color: isActive ? AppColors.success : Colors.red,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (r['address'] != null)
                    Text('📍 ${r['address']}', style: theme.textTheme.bodySmall),
                  if (r['rating'] != null)
                    Text('⭐ ${r['rating']} rating', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleRestaurantStatus(r['id'], isActive),
                        icon: Icon(isActive ? Icons.pause_circle_outline : Icons.play_circle_outline, size: 16),
                        label: Text(isActive ? 'Deactivate' : 'Activate'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isActive ? Colors.red : AppColors.success,
                          side: BorderSide(color: isActive ? Colors.red : AppColors.success),
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),
            ]),
          );
        },
      ),
    );
  }

  // ─── TAB 3: APPLICATIONS ──────────────────────────────────────────────────
  Widget _buildApplicationsTab(ThemeData theme) {
    if (_applications.isEmpty) {
      return _emptyState('No applications yet.', '📋', theme);
    }
    return RefreshIndicator(
      onRefresh: _fetchApplications,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _applications.length,
        itemBuilder: (ctx, i) {
          final app = _applications[i];
          final status = app['status'] as String? ?? 'pending';
          final isPending = status == 'pending';
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: isPending ? Border.all(color: Colors.amber.withOpacity(0.5)) : null,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(app['restaurant_name'] ?? '',
                    style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800))),
                _statusBadge(status),
              ]),
              const SizedBox(height: 8),
              _appInfoRow('📍', app['location']),
              _appInfoRow('🍴', app['cuisine_type']),
              _appInfoRow('📧', app['email']),
              _appInfoRow('📞', app['phone']),
              if (app['description'] != null && app['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(app['description'], style: theme.textTheme.bodySmall),
                ),
              ],
              if (isPending) ...[
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showConfirmDialog(
                        'Reject Application',
                        'Reject application from "${app['restaurant_name']}"?',
                        () => _updateApplicationStatus(app['id'], 'rejected'),
                      ),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showConfirmDialog(
                        'Approve Application',
                        'Approve application from "${app['restaurant_name']}"?',
                        () => _updateApplicationStatus(app['id'], 'approved'),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      child: Text('Approve', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
              ],
            ]),
          );
        },
      ),
    );
  }

  // ─── TAB 4: ORDERS ────────────────────────────────────────────────────────
  Widget _buildOrdersTab(ThemeData theme) {
    if (_recentOrders.isEmpty) {
      return _emptyState('No orders placed yet.', '📦', theme);
    }
    return RefreshIndicator(
      onRefresh: _fetchRecentOrders,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _recentOrders.length,
        itemBuilder: (ctx, i) {
          final o = _recentOrders[i];
          final status = o['status'] as String? ?? 'pending';
          final restaurant = (o['restaurants'] as Map?)??{};
          final profile = (o['profiles'] as Map?)??{};
          final amount = (o['total_amount'] as num?)?.toDouble() ?? 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('📦', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(restaurant['name'] ?? 'Unknown Restaurant',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                Text('By: ${profile['full_name'] ?? 'Customer'}', style: theme.textTheme.bodySmall),
                Text('ETB ${amount.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primary)),
              ])),
              _statusBadge(status),
            ]),
          );
        },
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────
  Widget _statCard(String icon, String label, String value, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ]),
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

  Widget _sectionTitle(String title, ThemeData theme) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800));
  }

  Widget _appInfoRow(String icon, dynamic value) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$icon  ${value.toString()}',
          style: const TextStyle(fontSize: 13, color: Colors.grey)),
    );
  }

  Widget _statusBadge(String status) {
    final color = switch (status) {
      'approved' || 'delivered' => AppColors.success,
      'rejected' || 'cancelled' => Colors.red,
      'preparing' => Colors.orange,
      'delivering' => const Color(0xFF6366F1),
      _ => Colors.amber,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(),
          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
    );
  }

  Widget _emptyState(String msg, String emoji, ThemeData theme) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(emoji, style: const TextStyle(fontSize: 56)),
      const SizedBox(height: 16),
      Text(msg, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
    ]));
  }

  Future<void> _showConfirmDialog(String title, String content, VoidCallback onConfirm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) onConfirm();
  }
}
