import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_theme.dart';
import 'providers/auth_provider.dart';
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

        // ── Owner Shell (Dashboard) ─────────────────────────────────────────
        ShellRoute(
          builder: (ctx, state, child) => OwnerShell(child: child),
          routes: [
            GoRoute(path: '/owner/dashboard', builder: (ctx, state) => const OwnerDashboardScreen()),
          ],
        ),

        // ── Superadmin Shell (Full App + Admin tab) ─────────────────────────
        ShellRoute(
          builder: (ctx, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(path: '/admin/home', builder: (ctx, state) => const HomeScreen()),
            GoRoute(path: '/admin/orders', builder: (ctx, state) => const OrdersScreen()),
            GoRoute(path: '/admin/profile', builder: (ctx, state) => const ProfileScreen()),
            GoRoute(path: '/admin/panel', builder: (ctx, state) => const SuperadminDashboardScreen()),
          ],
        ),

        // ── Shared routes (no shell) ────────────────────────────────────────
        GoRoute(
          path: '/restaurant/:id',
          builder: (ctx, state) => RestaurantDetailScreen(
            restaurantId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(path: '/cart', builder: (ctx, state) => const CartScreen()),
        GoRoute(path: '/owner/apply', builder: (ctx, state) => const OwnerApplyScreen()),
        GoRoute(path: '/superadmin/dashboard', builder: (ctx, state) {
          // Legacy redirect to new admin shell
          return const AdminShell(child: SuperadminDashboardScreen());
        }),
      ],
    );
  }
}


// ──────────────────────────────────────────────────────────────────────────────
// CUSTOMER SHELL  (Home / Orders / Profile)
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

// ──────────────────────────────────────────────────────────────────────────────
// OWNER SHELL  (Dashboard only — owners go straight to dashboard)
// ──────────────────────────────────────────────────────────────────────────────
class OwnerShell extends StatelessWidget {
  final Widget child;
  const OwnerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}

// ──────────────────────────────────────────────────────────────────────────────
// ADMIN SHELL  (Home / Orders / Profile + Admin Panel tab)
// ──────────────────────────────────────────────────────────────────────────────
class AdminShell extends StatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 3; // Default to admin panel tab
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
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
