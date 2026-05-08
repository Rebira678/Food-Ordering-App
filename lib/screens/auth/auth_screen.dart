import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  bool _rememberMe = false;

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
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Left panel — brand side
          Expanded(
            child: Container(
              color: const Color(0xFF0F201A),
              child: Stack(
                children: [
                  // Food background image at the bottom
                  Positioned(
                    bottom: 0, left: 0, right: 0, top: 0,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: 0.65,
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=800&auto=format&fit=crop'),
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFF0F201A),
                                  const Color(0xFF0F201A).withOpacity(0.0),
                                ],
                                stops: const [0.0, 0.4],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Row(
                          children: [
                            const Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 28),
                            const SizedBox(width: 12),
                            Text('SaffronEats',
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                )),
                          ],
                        ).animate().fadeIn(duration: 600.ms),
                        const SizedBox(height: 64),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.outfit(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2),
                            children: const [
                              TextSpan(text: 'Great food,\n'),
                              TextSpan(text: 'delivered '),
                              TextSpan(text: 'fast.', style: TextStyle(color: AppColors.primary)),
                            ],
                          ),
                        ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.04),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 400,
                          child: Text(
                            'Discover the best restaurants, order your favorites, and enjoy fast delivery at your doorstep.',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.6,
                            ),
                          ).animate().fadeIn(delay: 250.ms),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right panel — form side
          Expanded(
            child: Container(
              color: const Color(0xFFFAFAFA),
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                  child: Column(
                    children: [
                      // Top right language
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.language_rounded, size: 18, color: Colors.black54),
                              const SizedBox(width: 8),
                              Text('English', style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14)),
                              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                      // Form Card
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
                          child: Container(
                            width: 460,
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
                              ],
                              border: Border.all(color: Colors.grey.withOpacity(0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                            child: Text(
                              _isSignUp ? 'Create account!' : 'Welcome back!',
                              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.black),
                            ).animate().fadeIn(),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              _isSignUp ? 'Sign up to get started' : 'Login to your account to continue',
                              style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14),
                            ).animate().fadeIn(delay: 100.ms),
                          ),
                          const SizedBox(height: 32),

                          // Role toggle
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(children: [
                              _roleBtn('customer', 'Customer', Icons.person_outline_rounded),
                              _roleBtn('restaurant', 'Restaurant Owner', Icons.store_outlined),
                            ]),
                          ).animate().fadeIn(delay: 150.ms),
                          const SizedBox(height: 32),

                          // Fields
                          Text('Email address', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                          const SizedBox(height: 8),
                          _webField(_emailCtrl, 'Enter your email address', Icons.email_outlined, false),
                          const SizedBox(height: 20),
                          
                          Text('Password', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                          const SizedBox(height: 8),
                          _webField(_passwordCtrl, 'Enter your password', Icons.lock_outline, false,
                              obscure: _obscurePassword,
                              suffix: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.grey, size: 18),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              )),
                          
                          if (_role == 'customer' && _isSignUp) ...[
                            const SizedBox(height: 20),
                            Text('Delivery Address', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                            const SizedBox(height: 8),
                            _webField(_addressCtrl, 'Enter your home address', Icons.home_outlined, true),
                          ],
                          
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => setState(() => _rememberMe = !_rememberMe),
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _rememberMe ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                        color: _rememberMe ? const Color(0xFF0F201A) : Colors.grey.shade400,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Remember me', style: GoogleFonts.inter(color: Colors.grey.shade700, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                              if (!_isSignUp)
                                Text('Forgot password?', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(_isSignUp ? 'Sign Up' : 'Login',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 24),

                          Center(
                            child: GestureDetector(
                              onTap: () => setState(() => _isSignUp = !_isSignUp),
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                                    style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                  TextSpan(
                                    text: _isSignUp ? 'Login' : 'Sign up',
                                    style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                                TextSpan(text: 'By continuing, you agree to our ', style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 11)),
                                TextSpan(text: 'Terms of Service', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 11)),
                                TextSpan(text: ' and ', style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 11)),
                                TextSpan(text: 'Privacy Policy', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 11)),
                                TextSpan(text: '.', style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 11)),
                              ]),
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0F201A) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isActive ? Colors.white : Colors.black87),
              const SizedBox(width: 8),
              Text(label,
                  style: GoogleFonts.inter(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                    color: isActive ? Colors.white : Colors.black87,
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
      style: GoogleFonts.inter(color: Colors.black87, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 18),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  Widget _socialBtn(String name, IconData iconData, Color iconColor, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(iconData, size: 15, color: iconColor),
              const SizedBox(width: 8),
              Text(name, style: GoogleFonts.inter(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
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
