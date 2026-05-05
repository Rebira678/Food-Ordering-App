import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';

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
          SnackBar(content: Text('Submission failed: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
                  ),
                  const SizedBox(height: 24),
                  Text('Application Submitted!',
                      style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(
                    'We\'ve received your restaurant application. Our team will review it and get back to you within 2-3 business days.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.go('/auth'),
                    child: const Text('Back to Login'),
                  ),
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

              _field(_nameCtrl, 'Restaurant Name', Icons.store_rounded,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 14),

              _field(_locationCtrl, 'Full Address / Location', Icons.location_on_rounded,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 14),

              // Cuisine type dropdown
              DropdownButtonFormField<String>(
                value: _cuisineType,
                decoration: InputDecoration(
                  hintText: 'Cuisine Type',
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.restaurant_menu_rounded,
                      color: theme.colorScheme.onBackground.withOpacity(0.4)),
                ),
                items: _cuisines
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _cuisineType = v!),
              ),
              const SizedBox(height: 24),

              Text('Contact Information', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),

              _field(_phoneCtrl, 'Phone Number', Icons.phone_rounded,
                  inputType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 14),

              _field(_emailCtrl, 'Business Email', Icons.email_rounded,
                  inputType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 24),

              Text('Tell Us About Your Restaurant', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                style: TextStyle(color: theme.colorScheme.onBackground),
                decoration: InputDecoration(
                  hintText: 'Describe your restaurant, specialty dishes, and what makes you unique...',
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit Application'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType? inputType, String? Function(String?)? validator}) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: ctrl,
      keyboardType: inputType,
      style: TextStyle(color: theme.colorScheme.onBackground),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: theme.colorScheme.onBackground.withOpacity(0.4)),
      ),
    );
  }
}
