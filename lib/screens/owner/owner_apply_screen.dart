import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/web_theme.dart';

class OwnerApplyScreen extends StatefulWidget {
  const OwnerApplyScreen({super.key});

  @override
  State<OwnerApplyScreen> createState() => _OwnerApplyScreenState();
}

class _OwnerApplyScreenState extends State<OwnerApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _cuisineType = 'Ethiopian';
  bool _submitted = false;
  bool _isSubmitting = false;

  static const _cuisines = [
    'Ethiopian', 'Fast Food', 'Grill & BBQ', 'Italian', 'Mixed', 'Vegan'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        await Supabase.instance.client.from('owner_applications').insert({
          'restaurant_name': _nameCtrl.text.trim(),
          'location': _locationCtrl.text.trim(),
          'cuisine_type': _cuisineType,
          'phone': _phoneCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
        });
        setState(() => _submitted = true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            width: kIsWeb ? 400 : null,
            shape: kIsWeb ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) : null,
          ),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideWeb = kIsWeb && MediaQuery.of(context).size.width >= 900;

    if (isWideWeb) return _buildWebLayout(context);
    return _buildMobileLayout(context, theme);
  }

  // ── WEB LAYOUT ─────────────────────────────────────────────────────────────
  Widget _buildWebLayout(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        backgroundColor: WebColors.bg,
        body: Center(
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: WebColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: WebColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: AppColors.success, size: 48),
                ),
                const SizedBox(height: 32),
                Text('Application Submitted!', style: WebText.display(color: Colors.white).copyWith(fontSize: 32), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text(
                  'We\'ve received your restaurant application. Our team will review it and get back to you within 2-3 business days.',
                  style: WebText.body(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: PremiumButton(
                    label: 'Back to Login',
                    onPressed: () => context.go('/auth'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: WebColors.bg,
      body: Row(
        children: [
          // Left side: hero info
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF13161E), Color(0xFF0C0E14)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 48),
                      ),
                      const SizedBox(height: 40),
                      Text('Partner with SaffronEats.', style: WebText.display()),
                      const SizedBox(height: 24),
                      Text(
                        'Reach thousands of hungry customers in Adama, grow your restaurant business, and manage everything from our easy-to-use Partner Hub.',
                        style: WebText.body(),
                      ),
                      const SizedBox(height: 48),
                      _webBenefitRow(Icons.trending_up_rounded, 'Increase Revenue', 'Get more orders from a wider customer base.'),
                      const SizedBox(height: 24),
                      _webBenefitRow(Icons.dashboard_customize_rounded, 'Manage Easily', 'Track orders and update your menu in real-time.'),
                      const SizedBox(height: 24),
                      _webBenefitRow(Icons.support_agent_rounded, 'Local Support', 'Our Adama-based team is here to help you succeed.'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Right side: form
          Container(
            width: 560,
            color: WebColors.surface,
            child: Column(
              children: [
                // Nav bar
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: WebColors.border))),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back_rounded, color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            Text('Back', style: WebText.button(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(48),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Apply as a Partner', style: WebText.h1()),
                          const SizedBox(height: 8),
                          Text('Tell us a bit about your restaurant.', style: WebText.body()),
                          const SizedBox(height: 48),
                          
                          PremiumInput(
                            controller: _nameCtrl,
                            label: 'Restaurant Name',
                            prefixIcon: Icons.store_rounded,
                          ),
                          const SizedBox(height: 24),
                          
                          PremiumInput(
                            controller: _locationCtrl,
                            label: 'Full Address / Location',
                            prefixIcon: Icons.location_on_rounded,
                          ),
                          const SizedBox(height: 24),

                          Text('Cuisine Type', style: WebText.label()),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _cuisineType,
                            dropdownColor: WebColors.surfaceElevated,
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: WebColors.surfaceElevated,
                              prefixIcon: const Icon(Icons.restaurant_menu_rounded, color: WebColors.textMuted, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: WebColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: WebColors.border)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                            items: _cuisines.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (v) => setState(() => _cuisineType = v!),
                          ),
                          const SizedBox(height: 48),
                          
                          Text('Contact Details', style: WebText.h2()),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: PremiumInput(controller: _phoneCtrl, label: 'Phone Number', prefixIcon: Icons.phone_rounded)),
                              const SizedBox(width: 16),
                              Expanded(child: PremiumInput(controller: _emailCtrl, label: 'Business Email', prefixIcon: Icons.email_rounded)),
                            ],
                          ),
                          const SizedBox(height: 48),

                          Text('Description', style: WebText.h2()),
                          const SizedBox(height: 24),
                          PremiumInput(
                            controller: _descCtrl,
                            label: 'Tell Us About Your Restaurant',
                            hint: 'Describe your specialty dishes and what makes you unique...',
                            maxLines: 4,
                          ),
                          const SizedBox(height: 48),

                          SizedBox(
                            width: double.infinity,
                            child: PremiumButton(
                              label: 'Submit Application',
                              isLoading: _isSubmitting,
                              onPressed: _submit,
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _webBenefitRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: WebColors.surfaceElevated, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: WebText.h3()),
              const SizedBox(height: 4),
              Text(desc, style: WebText.body()),
            ],
          ),
        ),
      ],
    );
  }

  // ── MOBILE LAYOUT (unchanged) ───────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, ThemeData theme) {
    if (_submitted) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
                  ),
                  const SizedBox(height: 24),
                  Text('Application Submitted!', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(
                    'We\'ve received your restaurant application. Our team will review it and get back to you within 2-3 business days.',
                    style: theme.textTheme.bodyMedium, textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(onPressed: () => context.go('/auth'), child: const Text('Back to Login')),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Apply as a Partner'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Hero section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.8), AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🍽️', style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 12),
                    Text('Partner with SaffronEats',
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Reach thousands of hungry customers in Adama and grow your restaurant business with us.',
                        style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Restaurant Information', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              _field(_nameCtrl, 'Restaurant Name', Icons.store_rounded, validator: (v) => v!.isEmpty ? 'Required' : null, theme: theme),
              const SizedBox(height: 14),
              _field(_locationCtrl, 'Full Address / Location', Icons.location_on_rounded, validator: (v) => v!.isEmpty ? 'Required' : null, theme: theme),
              const SizedBox(height: 14),

              // Cuisine type dropdown
              DropdownButtonFormField<String>(
                value: _cuisineType,
                decoration: InputDecoration(
                  hintText: 'Cuisine Type', filled: true, fillColor: theme.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: Icon(Icons.restaurant_menu_rounded, color: theme.colorScheme.onBackground.withOpacity(0.4)),
                ),
                items: _cuisines.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _cuisineType = v!),
              ),
              const SizedBox(height: 24),

              Text('Contact Information', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              _field(_phoneCtrl, 'Phone Number', Icons.phone_rounded, inputType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Required' : null, theme: theme),
              const SizedBox(height: 14),
              _field(_emailCtrl, 'Business Email', Icons.email_rounded, inputType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Required' : null, theme: theme),
              const SizedBox(height: 24),

              Text('Tell Us About Your Restaurant', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                style: TextStyle(color: theme.colorScheme.onBackground),
                decoration: InputDecoration(
                  hintText: 'Describe your restaurant, specialty dishes, and what makes you unique...',
                  filled: true, fillColor: theme.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 28),

              ElevatedButton(onPressed: _isSubmitting ? null : _submit, child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Application')),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType? inputType, String? Function(String?)? validator, required ThemeData theme}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: inputType,
      style: TextStyle(color: theme.colorScheme.onBackground),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint, filled: true, fillColor: theme.cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        prefixIcon: Icon(icon, color: theme.colorScheme.onBackground.withOpacity(0.4)),
      ),
    );
  }
}
