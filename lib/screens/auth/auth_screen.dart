import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String _role = 'customer';
  bool _isSignUp = false;
  bool _isLoading = false;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _addressCtrl.dispose();
    _referralCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    if (_role == 'customer' && _isSignUp && _addressCtrl.text.trim().isEmpty) {
      _snack('Please provide a home address for delivery.');
      return;
    }

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    bool success = false;
    if (_isSignUp) {
      success = await auth.signUp(
        email: email,
        password: password,
        name: email.split('@').first,
        role: _role,
        address: _role == 'customer' ? _addressCtrl.text.trim() : null,
      );
    } else {
      success = await auth.signIn(email, password);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        final userRole = auth.user?.role?.toString();
        final userEmail = email.toLowerCase();

        if (userEmail == 'admin@saffroneats.com' || userRole == 'superadmin') {
          context.go('/admin/panel');
          return;
        }
        if (_role == 'restaurant' && (userRole == 'customer' || userRole == null)) {
          auth.logout();
          _snack('This portal is for Restaurants only. Use Order Food instead.');
          return;
        }
        if (_role == 'customer' && (userRole == 'owner' || userRole == 'superadmin')) {
          auth.logout();
          _snack('This tab is for Customers only. Use Partner Hub instead.');
          return;
        }

        if (userRole == 'superadmin') {
          context.go('/superadmin/dashboard');
        } else if (userRole == 'owner' || userRole == 'restaurant') {
          context.go('/owner/dashboard');
        } else {
          context.go('/');
        }
      } else {
        final errMsg = auth.lastErrorMessage ?? '';
        final isCredentialError = errMsg.toLowerCase().contains('invalid') ||
            errMsg.toLowerCase().contains('credentials') ||
            errMsg.toLowerCase().contains('password') ||
            errMsg.toLowerCase().contains('not found');
        if (!_isSignUp && isCredentialError) {
          _snack('Incorrect email or password. New here? Tap "Sign Up" below.');
        } else {
          _snack(errMsg.isNotEmpty ? errMsg : (_isSignUp ? 'Sign up failed. Try again.' : 'Sign in failed. Please check your credentials.'));
        }
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.primary,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isWideWeb = kIsWeb && MediaQuery.of(context).size.width >= 900;
    return isWideWeb ? _buildWebLayout(context) : _buildMobileLayout(context);
  }

  // ── WEB LAYOUT — split panel ───────────────────────────────────────────────
  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Row(
        children: [
          // Left panel — brand side
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F1117), Color(0xFF162010)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(top: -80, left: -80,
                    child: Container(width: 320, height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.07),
                      ),
                    ),
                  ),
                  Positioned(bottom: -60, right: -60,
                    child: Container(width: 260, height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(56),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Icon(Icons.restaurant_rounded, color: Colors.white, size: 26),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text('SaffronEats',
                                style: GoogleFonts.outfit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                )),
                          ],
                        ).animate().fadeIn(duration: 600.ms),
                        const SizedBox(height: 64),
                        Text(
                          'Discover the best\nfood in Adama.',
                          style: GoogleFonts.outfit(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.04),
                        const SizedBox(height: 20),
                        Text(
                          'Order from top local restaurants with fast delivery,\nreal-time tracking, and digital payment receipts.',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white54,
                            height: 1.7,
                          ),
                        ).animate().fadeIn(delay: 250.ms),
                        const SizedBox(height: 48),
                        // Feature bullets
                        ...[
                          ('Real-time order tracking', Icons.track_changes_rounded),
                          ('Digital payment receipts', Icons.receipt_long_rounded),
                          ('4 local restaurants', Icons.store_rounded),
                          ('Fast 25–45 min delivery', Icons.delivery_dining_rounded),
                        ].map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(e.$2, color: AppColors.primary, size: 17),
                              ),
                              const SizedBox(width: 14),
                              Text(e.$1,
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ],
                          ),
                        ).animate().fadeIn(delay: 300.ms)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right panel — form side
          Container(
            width: 480,
            color: const Color(0xFF080A0F),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSignUp ? 'Create your account' : 'Welcome back',
                      style: GoogleFonts.outfit(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 6),
                    Text(
                      _isSignUp
                          ? 'Join SaffronEats and start ordering today.'
                          : 'Sign in to continue to SaffronEats.',
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 32),

                    // Role toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1F2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        _roleBtn('customer', 'Order Food', Icons.shopping_bag_outlined),
                        _roleBtn('restaurant', 'Partner Hub', Icons.store_outlined),
                      ]),
                    ).animate().fadeIn(delay: 150.ms),
                    const SizedBox(height: 28),

                    // Fields
                    _webField(_emailCtrl, 'Email address', Icons.email_outlined, false),
                    const SizedBox(height: 14),
                    _webField(_passwordCtrl, 'Password', Icons.lock_outline, false,
                        obscure: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.white30, size: 18),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        )),
                    if (_role == 'customer' && _isSignUp) ...[
                      const SizedBox(height: 14),
                      _webField(_addressCtrl, 'Delivery Address', Icons.home_outlined, true),
                      const SizedBox(height: 14),
                      _webField(_referralCtrl, 'Referral Code (optional)', Icons.card_giftcard_rounded, true),
                    ],
                    const SizedBox(height: 28),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_isSignUp ? 'Create Account' : 'Sign In',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16)),
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () => setState(() => _isSignUp = !_isSignUp),
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                              style: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
                            ),
                            TextSpan(
                              text: _isSignUp ? 'Sign In' : 'Sign Up',
                              style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    if (_role == 'restaurant') ...[
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.push('/owner/apply'),
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(text: 'New restaurant? ', style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
                              TextSpan(text: 'Apply to list your restaurant.',
                                  style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleBtn(String role, String label, IconData icon) {
    final isActive = _role == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isActive ? Colors.white : Colors.white38),
              const SizedBox(width: 8),
              Text(label,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isActive ? Colors.white : Colors.white38,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _webField(TextEditingController ctrl, String hint, IconData icon, bool autoCapitalize,
      {bool obscure = false, Widget? suffix}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      autocorrect: false,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: Colors.white30, size: 18),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF1C1F2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  // ── MOBILE LAYOUT (unchanged) ───────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'Saffron', style: GoogleFonts.outfit(fontSize: 42, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  TextSpan(text: 'Eats', style: GoogleFonts.outfit(fontSize: 42, fontWeight: FontWeight.w900, color: theme.colorScheme.onBackground)),
                ]),
              ).animate().fadeIn(duration: 500.ms).scale(),
              const SizedBox(height: 8),
              Text('The premium food experience.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.5))
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  _roleBtnMobile('customer', 'Order Food', theme),
                  _roleBtnMobile('restaurant', 'Partner Hub', theme),
                ]),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _role == 'customer' ? (_isSignUp ? 'Create an account' : 'Sign in to order') : 'Restaurant Portal Login',
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 24),
              _textField(_emailCtrl, 'Email Address', Icons.email_outlined, autoCapitalize: false),
              const SizedBox(height: 16),
              _textField(_passwordCtrl, 'Password', Icons.lock_outline,
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: theme.colorScheme.onBackground.withOpacity(0.5), size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  )),
              if (_role == 'customer' && _isSignUp) ...[
                const SizedBox(height: 16),
                _textField(_addressCtrl, 'Delivery Address', Icons.home_outlined),
                const SizedBox(height: 16),
                _textField(_referralCtrl, 'Referral Code (Optional)', Icons.card_giftcard_rounded),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Sign Up",
                  style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
              if (_role == 'restaurant') ...[
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => context.push('/owner/apply'),
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: 'Want to list your restaurant with us? ',
                        style: GoogleFonts.inter(color: theme.colorScheme.onBackground.withOpacity(0.5))),
                    TextSpan(text: 'Apply here.',
                        style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ]), textAlign: TextAlign.center),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleBtnMobile(String role, String label, ThemeData theme) {
    final isActive = _role == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : theme.colorScheme.onBackground)),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String hint, IconData icon,
      {bool obscure = false, bool autoCapitalize = true, Widget? suffix}) {
    final theme = Theme.of(context);
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      autocorrect: false,
      style: TextStyle(color: theme.colorScheme.onBackground),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: theme.colorScheme.onBackground.withOpacity(0.5)),
        suffixIcon: suffix,
      ),
    );
  }
}
