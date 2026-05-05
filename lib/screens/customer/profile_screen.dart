import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _activeSection = '';
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _pushEnabled = true;
  bool _emailPromos = false;
  List<Map<String, String>> _paymentMethods = [
    {'id': '1', 'type': 'Mastercard', 'last4': '4022'}
  ];

  final _avatarOptions = [
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Aneka',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Bibi',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Caleb',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Dave',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Ezra',
  ];
  int _selectedAvatarIdx = 0;
  bool _showAvatarPicker = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl.text = user?.name ?? '';
    _emailCtrl.text = user?.email ?? '';
    _addressCtrl.text = user?.address ?? '';
    _pushEnabled = user?.pushEnabled ?? true;
    _emailPromos = user?.emailEnabled ?? false;
    
    if (user?.avatarUrl != null) {
      final idx = _avatarOptions.indexOf(user!.avatarUrl!);
      if (idx != -1) _selectedAvatarIdx = idx;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final auth = context.read<AuthProvider>();
    await auth.updateUser(auth.user!.copyWith(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      avatarUrl: _avatarOptions[_selectedAvatarIdx],
    ));
    setState(() => _activeSection = '');
    _snack('✅ Profile Updated Successfully!');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.success,
    ));
  }

  Widget _accordion(String key, String icon, String title, Widget body, ThemeData theme) {
    final isOpen = _activeSection == key;
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _activeSection = isOpen ? '' : key),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(16),
                bottom: isOpen ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$icon  $title', style: theme.textTheme.titleSmall),
                AnimatedRotation(
                  turns: isOpen ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: body,
          ),
          crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.user;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () => setState(() => _showAvatarPicker = !_showAvatarPicker),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(user?.avatarUrl ?? _avatarOptions[_selectedAvatarIdx]),
                          backgroundColor: theme.cardColor,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.edit, color: Colors.white, size: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.name ?? 'Guest User', style: theme.textTheme.headlineMedium),
                  Text(user?.email ?? '', style: theme.textTheme.bodySmall),
                  if (user?.address != null) ...[
                    const SizedBox(height: 4),
                    Text('📍 ${user!.address}', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('💎 VIP Elite Tier • 2,450 pts',
                        style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),

            // Referral box
            if (user?.referralCode != null)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Column(
                  children: [
                    Text('YOUR REFERRAL CODE', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1, color: theme.colorScheme.onBackground.withOpacity(0.6))),
                    const SizedBox(height: 8),
                    Text(user!.referralCode!, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text('Share this code and you both get discounts!', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                    if (user.availableDiscounts.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('🎉 You have discounts at ${user.availableDiscounts.length} restaurant(s)!',
                          style: GoogleFonts.inter(color: AppColors.success, fontWeight: FontWeight.w700)),
                    ]
                  ],
                ),
              ),

            // Avatar picker
            if (_showAvatarPicker)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Text('Choose Your Avatar', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_avatarOptions.length, (i) => GestureDetector(
                          onTap: () async {
                            setState(() { _selectedAvatarIdx = i; _showAvatarPicker = false; });
                            // Save immediately
                            await auth.updateUser(auth.user!.copyWith(avatarUrl: _avatarOptions[i]));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: i == _selectedAvatarIdx ? AppColors.primary : Colors.transparent, width: 2),
                            ),
                            child: CircleAvatar(radius: 30, backgroundImage: NetworkImage(_avatarOptions[i])),
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
              ),

            // Accordions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                _accordion('Profile', '👤', 'Manage Information', Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Full Name')),
                    const SizedBox(height: 12),
                    TextField(controller: _emailCtrl, decoration: const InputDecoration(hintText: 'Email')),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _saveProfile, child: const Text('Save Profile Data')),
                  ],
                ), theme),

                _accordion('Payment', '💳', 'Payment Methods', Column(
                  children: [
                    ..._paymentMethods.map((p) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('${p['type']} •••• ${p['last4']}', style: theme.textTheme.titleSmall),
                          trailing: TextButton(
                            onPressed: () => setState(() => _paymentMethods.removeWhere((m) => m['id'] == p['id'])),
                            child: const Text('Remove', style: TextStyle(color: AppColors.errorRed)),
                          ),
                        )),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _paymentMethods.add({'id': DateTime.now().millisecondsSinceEpoch.toString(), 'type': 'Visa', 'last4': '9981'})),
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Card'),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
                    ),
                  ],
                ), theme),

                _accordion('Addresses', '📍', 'Delivery Locations', Column(
                  children: [
                    TextField(controller: _addressCtrl, decoration: const InputDecoration(hintText: 'Street Address...')),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _saveProfile, child: const Text('Update Address')),
                  ],
                ), theme),

                _accordion('Alerts', '🔔', 'App Notifications', Column(
                  children: [
                    _switchRow('Push Notifications', 'Stay updated on your orders', _pushEnabled, () async {
                      setState(() => _pushEnabled = !_pushEnabled);
                      // Save directly to avoid auth state refresh causing sign-out
                      final uid = Supabase.instance.client.auth.currentUser?.id;
                      if (uid != null) {
                        await Supabase.instance.client.from('profiles')
                            .update({'push_enabled': _pushEnabled}).eq('id', uid);
                      }
                    }, theme),
                    _switchRow('Email Promos', 'Get exclusive deals', _emailPromos, () async {
                      setState(() => _emailPromos = !_emailPromos);
                      final uid = Supabase.instance.client.auth.currentUser?.id;
                      if (uid != null) {
                        await Supabase.instance.client.from('profiles')
                            .update({'email_enabled': _emailPromos}).eq('id', uid);
                      }
                    }, theme),
                  ],
                ), theme),
              ]),
            ),

            // App settings
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text('APP SETTINGS', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1, color: theme.colorScheme.onBackground.withOpacity(0.4))),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  final isDark = theme.brightness == Brightness.dark;
                  themeProvider.toggleTheme(!isDark);
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Text(
                      theme.brightness == Brightness.dark ? '☀️ Switch to Light Mode' : '🌙 Switch to Dark Mode',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE2E2),
                  foregroundColor: const Color(0xFFDC2626),
                  elevation: 0,
                ),
                onPressed: () {
                  auth.logout();
                  context.go('/auth');
                },
                child: Text('Sign Out from Account', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: const Color(0xFFDC2626))),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _switchRow(String title, String subtitle, bool value, VoidCallback onToggle, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: theme.textTheme.titleSmall),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ]),
          ),
          Switch(value: value, onChanged: (_) => onToggle(), activeColor: AppColors.success),
        ],
      ),
    );
  }
}
