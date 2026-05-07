import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/customer/home_screen.dart';
import 'screens/customer/restaurant_detail_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/orders_screen.dart';
import 'screens/customer/profile_screen.dart';
import 'screens/owner/owner_dashboard_screen.dart';
import 'screens/owner/owner_apply_screen.dart';
import 'screens/superadmin/superadmin_dashboard_screen.dart';

class SaffronEatsApp extends StatefulWidget {
  const SaffronEatsApp({super.key});

  @override
  State<SaffronEatsApp> createState() => _SaffronEatsAppState();
}

class _SaffronEatsAppState extends State<SaffronEatsApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _buildRouter();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'SaffronEats',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/auth',
      routes: [
        GoRoute(
          path: '/auth',
          builder: (ctx, state) => const AuthScreen(),
        ),

        // ── Customer Shell (Home, Orders, Profile) ──────────────────────────
        ShellRoute(
          builder: (ctx, state, child) => CustomerShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (ctx, state) => const HomeScreen()),
            GoRoute(path: '/orders', builder: (ctx, state) => const OrdersScreen()),
            GoRoute(path: '/profile', builder: (ctx, state) => const ProfileScreen()),
          ],
        ),

        // ── Owner Shell ─────────────────────────────────────────────────────
        ShellRoute(
          builder: (ctx, state, child) => OwnerShell(child: child),
          routes: [
            GoRoute(path: '/owner/dashboard', builder: (ctx, state) => const OwnerDashboardScreen()),
          ],
        ),

        // ── Superadmin Shell ────────────────────────────────────────────────
        ShellRoute(
          builder: (ctx, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(path: '/admin/home', builder: (ctx, state) => const HomeScreen()),
            GoRoute(path: '/admin/orders', builder: (ctx, state) => const OrdersScreen()),
            GoRoute(path: '/admin/profile', builder: (ctx, state) => const ProfileScreen()),
            GoRoute(path: '/admin/panel', builder: (ctx, state) => const SuperadminDashboardScreen()),
          ],
        ),

        // ── Shared routes ───────────────────────────────────────────────────
        GoRoute(
          path: '/restaurant/:id',
          builder: (ctx, state) => RestaurantDetailScreen(
            restaurantId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(path: '/cart', builder: (ctx, state) => const CartScreen()),
        GoRoute(path: '/owner/apply', builder: (ctx, state) => const OwnerApplyScreen()),
        GoRoute(path: '/superadmin/dashboard', builder: (ctx, state) {
          return const AdminShell(child: SuperadminDashboardScreen());
        }),
      ],
    );
  }
}


// ──────────────────────────────────────────────────────────────────────────────
// CUSTOMER SHELL
// Mobile: bottom nav bar (unchanged)
// Web: full-width top navigation bar (website feel)
// ──────────────────────────────────────────────────────────────────────────────
class CustomerShell extends StatefulWidget {
  final Widget child;
  const CustomerShell({super.key, required this.child});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _currentIndex = 0;
  static const _tabs = ['/', '/orders', '/profile'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ── WEB LAYOUT ──
    if (kIsWeb && MediaQuery.of(context).size.width >= 768) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            _WebTopNav(
              currentIndex: _currentIndex,
              onTabChanged: (i) {
                setState(() => _currentIndex = i);
                context.go(_tabs[i]);
              },
            ),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    // ── MOBILE LAYOUT (unchanged) ──
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() => _currentIndex = i);
          context.go(_tabs[i]);
        },
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_menu_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

// ── Web top navigation bar ──────────────────────────────────────────────────
class _WebTopNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTabChanged;

  const _WebTopNav({required this.currentIndex, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                // Logo
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Text('🍛', style: TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(width: 10),
                      Text('SaffronEats',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          )),
                    ],
                  ),
                ),
                const Spacer(),
                // Nav links
                _NavLink(label: 'Browse', active: currentIndex == 0, onTap: () => onTabChanged(0)),
                const SizedBox(width: 8),
                _NavLink(label: 'My Orders', active: currentIndex == 1, onTap: () => onTabChanged(1)),
                const SizedBox(width: 8),
                _NavLink(label: 'Profile', active: currentIndex == 2, onTap: () => onTabChanged(2)),
                const SizedBox(width: 16),
                // Cart button
                TextButton.icon(
                  onPressed: () => context.push('/cart'),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: Text(
                    'Cart${cart.itemCount > 0 ? " (${cart.itemCount})" : ""}',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                // Sign out
                if (auth.user != null)
                  TextButton(
                    onPressed: () {
                      auth.logout();
                      context.go('/auth');
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
                    child: Text('Sign Out', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: active ? AppColors.primary : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Text(label,
          style: GoogleFonts.outfit(
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
            fontSize: 15,
            decoration: active ? TextDecoration.underline : null,
            decorationColor: AppColors.primary,
            decorationThickness: 2,
          )),
    );
  }
}


// ──────────────────────────────────────────────────────────────────────────────
// OWNER SHELL
// ──────────────────────────────────────────────────────────────────────────────
class OwnerShell extends StatelessWidget {
  final Widget child;
  const OwnerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}

// ──────────────────────────────────────────────────────────────────────────────
// ADMIN SHELL
// ──────────────────────────────────────────────────────────────────────────────
class AdminShell extends StatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 3;
  static const _tabs = ['/admin/home', '/admin/orders', '/admin/profile', '/admin/panel'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() => _currentIndex = i);
          context.go(_tabs[i]);
        },
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: AppColors.primary.withOpacity(0.15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_menu_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
