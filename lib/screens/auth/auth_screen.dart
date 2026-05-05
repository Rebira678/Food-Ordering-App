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
  String _role = 'customer'; // 'customer' | 'restaurant'
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide a home address for delivery.')),
      );
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
        
        debugPrint('👤 LOGGED IN AS: $userRole ($userEmail)');

        // Admin Bypass & Tab Restrictions
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
        _snack(auth.lastErrorMessage ?? (_isSignUp ? 'Sign up failed.' : 'Sign in failed.'));
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Saffron',
                      style: GoogleFonts.outfit(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: 'Eats',
                      style: GoogleFonts.outfit(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).scale(),
              const SizedBox(height: 8),
              Text(
                'The premium food experience.',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.5)),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 40),
              // Role toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _roleBtn('customer', '🍽️ Order Food', theme),
                    _roleBtn('restaurant', '🏪 Partner Hub', theme),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 32),
              // Form title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _role == 'customer'
                      ? (_isSignUp ? 'Create an account' : 'Sign in to order')
                      : 'Restaurant Portal Login',
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 24),
              // Fields
              _textField(_emailCtrl, 'Email Address', Icons.email_outlined,
                  autoCapitalize: false),
              const SizedBox(height: 16),
              _textField(
                _passwordCtrl,
                'Password',
                Icons.lock_outline,
                obscure: _obscurePassword,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              if (_role == 'customer' && _isSignUp) ...[
                const SizedBox(height: 16),
                _textField(_addressCtrl,
                    'Registration Home / Delivery Address', Icons.home_outlined),
                const SizedBox(height: 16),
                _textField(_referralCtrl, 'Referral Code (Optional)',
                    Icons.card_giftcard_rounded),
              ],
              const SizedBox(height: 24),
              // Submit
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign In'
                      : "Don't have an account? Sign Up",
                  style: GoogleFonts.outfit(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_role == 'restaurant') ...[
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => context.push('/owner/apply'),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Want to list your restaurant with us? ',
                          style: GoogleFonts.inter(
                              color: theme.colorScheme.onBackground
                                  .withOpacity(0.5)),
                        ),
                        TextSpan(
                          text: 'Apply here.',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleBtn(String role, String label, ThemeData theme) {
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
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              color: isActive
                  ? Colors.white
                  : theme.colorScheme.onBackground,
            ),
          ),
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
      textCapitalization:
          autoCapitalize ? TextCapitalization.none : TextCapitalization.none,
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
