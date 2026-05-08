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
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _pushEnabled = true;
  bool _emailPromos = false;
  List<Map<String, String>> _paymentMethods = [
    {'id': '1', 'type': 'Mastercard', 'last4': '4022'}
  ];

  final _avatarOptions = [
    'https://api.dicebear.com/7.x/avataaars/png?seed=Felix',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Aneka',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Bibi',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Caleb',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Dave',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Ezra',
  ];
  int _selectedAvatarIdx = 0;
  bool _showAvatarPicker = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl.text = user?.name ?? '';
    _emailCtrl.text = user?.email ?? '';
    _phoneCtrl.text = user?.phone ?? '';
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
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final auth = context.read<AuthProvider>();
    await auth.updateUser(auth.user!.copyWith(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      avatarUrl: _avatarOptions[_selectedAvatarIdx],
      pushEnabled: _pushEnabled,
      emailEnabled: _emailPromos,
    ));
    _snack('✅ Profile Updated Successfully!');
  }

  void _showEditProfileDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF181818) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        title: Text('Edit Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogTextField(_nameCtrl, 'Full Name', isDark),
            const SizedBox(height: 12),
            _dialogTextField(_emailCtrl, 'Email', isDark),
            const SizedBox(height: 12),
            _dialogTextField(_phoneCtrl, 'Phone Number', isDark),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () { _saveProfile(); Navigator.pop(ctx); },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _dialogTextField(TextEditingController ctrl, String label, bool isDark) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade400)),
      ),
    );
  }

  void _showEditAddressDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF181818) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        title: Text('Edit Address', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: textColor)),
        content: _dialogTextField(_addressCtrl, 'Delivery Address', isDark),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () { _saveProfile(); Navigator.pop(ctx); },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF181818) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: dialogBg,
          title: Text('Notification Preferences', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Push Notifications', style: GoogleFonts.inter(fontSize: 14, color: textColor)),
                value: _pushEnabled,
                activeColor: AppColors.success,
                onChanged: (v) { setDialogState(() => _pushEnabled = v); setState(() => _pushEnabled = v); },
              ),
              SwitchListTile(
                title: Text('Email Promos', style: GoogleFonts.inter(fontSize: 14, color: textColor)),
                value: _emailPromos,
                activeColor: AppColors.success,
                onChanged: (v) { setDialogState(() => _emailPromos = v); setState(() => _emailPromos = v); },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () { _saveProfile(); Navigator.pop(ctx); },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF181818) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    String selectedPayment = _paymentMethods.isNotEmpty ? _paymentMethods.first['type']! : 'Telebirr';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: dialogBg,
          title: Text('Payment Method', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('Telebirr', style: GoogleFonts.inter(color: textColor)),
                value: 'Telebirr',
                groupValue: selectedPayment,
                activeColor: AppColors.primary,
                onChanged: (v) => setDialogState(() => selectedPayment = v!),
              ),
              RadioListTile<String>(
                title: Text('Commercial Bank of Ethiopia (CBE)', style: GoogleFonts.inter(color: textColor)),
                value: 'CBE',
                groupValue: selectedPayment,
                activeColor: AppColors.primary,
                onChanged: (v) => setDialogState(() => selectedPayment = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                setState(() => _paymentMethods = [{'id': '1', 'type': selectedPayment, 'last4': '****'}]);
                _snack('✅ Payment Method Saved!');
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.success,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF181818) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/'),
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textColor),
                      ),
                      Row(
                    children: [
                      const Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text('SaffronEats', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: textColor)),
                    ],
                  ),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.notifications_none_rounded, size: 26, color: textColor),
                      ),
                      Positioned(
                        right: 0, top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: Text('3', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 12),
                  Text('Profile Settings', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: textColor)),
                  const SizedBox(height: 4),
                  Text('Manage your personal information and preferences', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500)),
                  const SizedBox(height: 24),

                  // Profile Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundImage: NetworkImage(user?.avatarUrl ?? _avatarOptions[_selectedAvatarIdx]),
                                ),
                                Positioned(
                                  right: -2, bottom: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                                    ),
                                    child: Icon(Icons.camera_alt_outlined, size: 14, color: textColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user?.name ?? 'Guest User', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
                                  const SizedBox(height: 4),
                                  Text(user?.phone ?? '+251 91 234 5678', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500)),
                                  const SizedBox(height: 2),
                                  Text(user?.email ?? 'user@example.com', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Profile Completion', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
                            Text('90% Complete', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: 0.9,
                            backgroundColor: AppColors.primary.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text('Account Settings', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                  const SizedBox(height: 12),
                  _settingsTile(
                    title: 'Profile Information',
                    subtitle: 'Update your personal details',
                    icon: Icons.person_outline_rounded,
                    iconColor: AppColors.primary,
                    bgColor: AppColors.primary.withOpacity(0.1),
                    isSelected: true,
                    onTap: _showEditProfileDialog,
                    cardColor: cardColor,
                    textColor: textColor,
                    isDark: isDark,
                  ),
                  _settingsTile(
                    title: 'Addresses',
                    subtitle: 'Manage your saved addresses',
                    icon: Icons.location_on_outlined,
                    iconColor: AppColors.success,
                    bgColor: AppColors.success.withOpacity(0.1),
                    onTap: _showEditAddressDialog,
                    cardColor: cardColor,
                    textColor: textColor,
                    isDark: isDark,
                  ),
                  _settingsTile(
                    title: 'Payment Methods',
                    subtitle: _paymentMethods.isNotEmpty ? _paymentMethods.first['type']! : 'Telebirr',
                    icon: Icons.credit_card_outlined,
                    iconColor: AppColors.success,
                    bgColor: AppColors.success.withOpacity(0.1),
                    onTap: _showPaymentDialog,
                    cardColor: cardColor,
                    textColor: textColor,
                    isDark: isDark,
                  ),
                  _settingsTile(
                    title: 'Notification Preferences',
                    subtitle: 'Choose your notification settings',
                    icon: Icons.notifications_none_rounded,
                    iconColor: AppColors.success,
                    bgColor: AppColors.success.withOpacity(0.1),
                    onTap: _showNotificationsDialog,
                    cardColor: cardColor,
                    textColor: textColor,
                    isDark: isDark,
                  ),
                  _settingsTile(
                    title: 'Privacy & Security',
                    subtitle: 'Manage privacy and account security',
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.success,
                    bgColor: AppColors.success.withOpacity(0.1),
                    onTap: () => _snack('Privacy & Security not yet implemented.'),
                    cardColor: cardColor,
                    textColor: textColor,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),
                  Text('Preferences', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                  const SizedBox(height: 12),
                  _settingsTile(
                    title: 'Food Preferences',
                    subtitle: 'Vegetarian, Spicy food & more',
                    icon: Icons.restaurant_menu_rounded,
                    iconColor: AppColors.success,
                    bgColor: AppColors.success.withOpacity(0.1),
                    onTap: () => _snack('Food Preferences updated locally.'),
                    cardColor: cardColor,
                    textColor: textColor,
                    isDark: isDark,
                  ),
                  _settingsTile(
                    title: 'Allergies',
                    subtitle: 'Manage your food allergies',
                    icon: Icons.health_and_safety_outlined,
                    iconColor: AppColors.success,
                    bgColor: AppColors.success.withOpacity(0.1),
                    onTap: () => _snack('Allergies updated locally.'),
                    cardColor: cardColor,
                    textColor: textColor,
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 24),
                  Text('App Settings', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                  const SizedBox(height: 12),
                  _settingsTile(
                    title: 'Theme',
                    subtitle: isDark ? 'Dark Mode Active' : 'Light Mode Active',
                    icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    iconColor: Colors.blueAccent,
                    bgColor: Colors.blueAccent.withOpacity(0.1),
                    onTap: () => themeProvider.toggleTheme(!isDark),
                    cardColor: cardColor,
                    textColor: textColor,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B4332).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1B4332).withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B4332).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.security_rounded, color: Color(0xFF1B4332), size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your account is secure', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? AppColors.success : const Color(0xFF0F201A))),
                              const SizedBox(height: 2),
                              Text('We keep your data safe and private.', style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      auth.logout();
                      context.go('/auth');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text('Logout', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFDC2626))),
                          ),
                          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _settingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
    required Color cardColor,
    required Color textColor,
    required bool isDark,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? AppColors.primary.withOpacity(0.1) : const Color(0xFFFFF7ED)) : cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary.withOpacity(0.3) : (isDark ? Colors.white12 : Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: isSelected ? AppColors.primary : textColor)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isSelected ? AppColors.primary : Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
