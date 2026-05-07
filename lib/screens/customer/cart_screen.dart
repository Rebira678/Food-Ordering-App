import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../models/cart_item.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/web_theme.dart';
import '../../core/services/image_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _addressMode = 'profile'; // 'profile' | 'new'
  final _nameCtrl = TextEditingController();
  final _newAddressCtrl = TextEditingController();
  final double _tip = 0;
  
  // Track XFile for each restaurant to allow separate payments (works on web + mobile)
  final Map<String, XFile?> _paymentFiles = {};
  final Map<String, bool> _uploadingStatus = {};

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl.text = user?.name ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _newAddressCtrl.dispose();
    super.dispose();
  }

  void _handleCheckout(String restaurantId, List<CartItem> items, double subtotal) async {
    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    final orders = context.read<OrderProvider>();

    if (_nameCtrl.text.trim().isEmpty) {
      _snack('Please enter your name for the order.');
      return;
    }
    
    final addr = _addressMode == 'profile'
        ? auth.user?.address
        : _newAddressCtrl.text.trim();
        
    if (addr == null || addr.isEmpty) {
      _snack('Please provide a valid delivery address.');
      return;
    }
    
    final paymentFile = _paymentFiles[restaurantId];
    if (paymentFile == null) {
      _snack('Please upload payment receipt for ${items.first.restaurantName}.');
      return;
    }

    setState(() => _uploadingStatus[restaurantId] = true);
    
    try {
      final imageUrl = await ImageService.uploadPaymentScreenshot(paymentFile);
      if (imageUrl == null) {
        _snack('Failed to upload receipt. Please try again.');
        return;
      }

      final success = await orders.addOrder(
        Order(
          id: 'ORD${Random().nextInt(10000)}',
          items: items,
          total: subtotal,
          tip: _tip,
          status: OrderStatus.placed,
          date: DateTime.now().toIso8601String(),
          restaurantName: items.first.restaurantName,
          paymentImageUrl: imageUrl,
        ),
        restaurantId,
        address: addr,
      );

      if (success) {
        // Remove only these items from cart
        for (var item in items) {
          cart.removeItem(item.id);
        }
        if (mounted) _showOrderSuccess(items.first.restaurantName);
      } else {
        _snack('Failed to place order. Please try again.');
      }
    } catch (e) {
      _snack('Something went wrong: $e');
    } finally {
      setState(() => _uploadingStatus[restaurantId] = false);
    }
  }

  void _showOrderSuccess(String restaurantName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: kIsWeb ? WebColors.surface : Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('🎉', style: TextStyle(fontSize: 40))),
              ),
              const SizedBox(height: 24),
              Text('Order Sent!',
                  style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: kIsWeb ? Colors.white : AppColors.darkText)),
              const SizedBox(height: 12),
              Text(
                'Your order has been successfully sent to $restaurantName.\nYou will be notified when it\'s being prepared.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: kIsWeb ? Colors.white70 : Colors.grey, height: 1.6, fontSize: 15),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: kIsWeb ? PremiumButton(
                  label: 'Track My Order',
                  color: AppColors.success,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    final cartProvider = context.read<CartProvider>();
                    if (cartProvider.items.isEmpty) context.go('/orders');
                  },
                ) : ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    final cartProvider = context.read<CartProvider>();
                    if (cartProvider.items.isEmpty) {
                      context.go('/orders');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Track My Order',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickPaymentImage(String restaurantId) async {
    final xfile = await ImageService.pickImage();
    if (xfile != null) {
      setState(() => _paymentFiles[restaurantId] = xfile as XFile);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      width: kIsWeb ? 400 : null,
      shape: kIsWeb ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)) : null,
      backgroundColor: kIsWeb ? const Color(0xFF1E2130) : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.read<AuthProvider>();

    final Map<String, List<CartItem>> groupedItems = {};
    for (var item in cart.items) {
      groupedItems.putIfAbsent(item.restaurantId, () => []).add(item);
    }

    final isWideWeb = kIsWeb && MediaQuery.of(context).size.width >= 900;
    if (isWideWeb) return _buildWebLayout(context, cart, auth, groupedItems);
    return _buildMobileLayout(context, cart, auth, groupedItems);
  }

  // ── WEB LAYOUT ─────────────────────────────────────────────────────────────
  Widget _buildWebLayout(BuildContext context, CartProvider cart, AuthProvider auth, Map<String, List<CartItem>> groupedItems) {
    return Scaffold(
      backgroundColor: WebColors.bg,
      body: Column(
        children: [
          // Top Nav
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 48),
            decoration: const BoxDecoration(
              color: WebColors.surface,
              border: Border(bottom: BorderSide(color: WebColors.border)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Row(children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(9)),
                      child: const Center(child: Icon(Icons.restaurant_rounded, color: Colors.white, size: 18)),
                    ),
                    const SizedBox(width: 10),
                    Text('SaffronEats', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  ]),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Continue Shopping'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(color: WebColors.surfaceElevated, borderRadius: BorderRadius.circular(24)),
                          child: const Icon(Icons.shopping_bag_outlined, size: 36, color: AppColors.primary),
                        ),
                        const SizedBox(height: 24),
                        Text('Your cart is empty', style: WebText.h2()),
                        const SizedBox(height: 8),
                        Text('Looks like you haven\'t added any food yet.', style: WebText.body()),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: 240,
                          child: PremiumButton(
                            label: 'Browse Restaurants',
                            onPressed: () => context.go('/'),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: WebContainer(
                      maxWidth: 1000,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column: Items
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Your Order', style: WebText.h1()),
                                const SizedBox(height: 32),
                                ...groupedItems.entries.map((entry) {
                                  final restId = entry.key;
                                  final items = entry.value;
                                  final restName = items.first.restaurantName;
                                  final subtotal = items.fold(0.0, (sum, i) => sum + i.price * i.quantity);
                                  final total = subtotal + 25.0 + _tip;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 32),
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: WebColors.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: WebColors.border),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.store_rounded, color: AppColors.primary, size: 20),
                                            const SizedBox(width: 10),
                                            Text(restName, style: WebText.h2()),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        ...items.map((item) => Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(color: WebColors.surfaceElevated, borderRadius: BorderRadius.circular(6)),
                                                child: Text('${item.quantity}x', style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w800)),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(child: Text(item.name, style: WebText.body(color: Colors.white))),
                                              Text('ETB ${(item.price * item.quantity).toStringAsFixed(0)}', style: WebText.h3()),
                                              const SizedBox(width: 16),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white38),
                                                onPressed: () => cart.removeItem(item.id),
                                                hoverColor: Colors.redAccent.withOpacity(0.1),
                                              ),
                                            ],
                                          ),
                                        )),
                                        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: WebDivider()),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Delivery Fee', style: WebText.body()),
                                            Text('ETB 25', style: WebText.h3()),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Total for $restName', style: WebText.body(color: Colors.white)),
                                            Text('ETB ${total.toStringAsFixed(0)}', style: WebText.h2(color: AppColors.primary)),
                                          ],
                                        ),
                                        const SizedBox(height: 32),
                                        // Payment
                                        Text('Payment Receipt', style: WebText.h3()),
                                        const SizedBox(height: 8),
                                        Text('Please transfer the total amount via Telebirr or CBE Birr and upload the screenshot.', style: WebText.caption()),
                                        const SizedBox(height: 16),
                                        GestureDetector(
                                          onTap: () => _pickPaymentImage(restId),
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 24),
                                              decoration: BoxDecoration(
                                                color: _paymentFiles[restId] != null ? AppColors.success.withOpacity(0.1) : WebColors.surfaceElevated,
                                                borderRadius: BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: _paymentFiles[restId] != null ? AppColors.success : WebColors.border,
                                                  style: BorderStyle.solid,
                                                ),
                                              ),
                                              child: Center(
                                                child: _uploadingStatus[restId] == true
                                                  ? const CircularProgressIndicator(color: AppColors.primary)
                                                  : Column(
                                                      children: [
                                                        Icon(
                                                          _paymentFiles[restId] != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                                                          size: 32,
                                                          color: _paymentFiles[restId] != null ? AppColors.success : Colors.white38,
                                                        ),
                                                        const SizedBox(height: 12),
                                                        Text(
                                                          _paymentFiles[restId] != null ? 'Receipt Uploaded: ${_paymentFiles[restId]!.name}' : 'Click to Upload Screenshot',
                                                          style: WebText.button(color: _paymentFiles[restId] != null ? AppColors.success : Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        PremiumButton(
                                          label: 'Place Order from $restName',
                                          isLoading: _uploadingStatus[restId] == true,
                                          onPressed: () => _handleCheckout(restId, items, subtotal),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48),
                          // Right column: Delivery Details
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: WebColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: WebColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Delivery Details', style: WebText.h2()),
                                  const SizedBox(height: 24),
                                  PremiumInput(
                                    controller: _nameCtrl,
                                    label: 'Recipient Name',
                                    prefixIcon: Icons.person_outline_rounded,
                                  ),
                                  const SizedBox(height: 24),
                                  Text('Delivery Address', style: WebText.label()),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: WebColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: WebColors.border),
                                    ),
                                    child: Row(
                                      children: [
                                        _webAddrTab('Profile Address', _addressMode == 'profile', () => setState(() => _addressMode = 'profile')),
                                        _webAddrTab('New Address', _addressMode == 'new', () => setState(() => _addressMode = 'new')),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (_addressMode == 'profile')
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(child: Text(auth.user?.address ?? 'No address found. Update your profile.', style: WebText.body(color: Colors.white))),
                                        ],
                                      ),
                                    )
                                  else
                                    PremiumInput(
                                      controller: _newAddressCtrl,
                                      label: 'Enter New Address',
                                      prefixIcon: Icons.location_on_rounded,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _webAddrTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(label, textAlign: TextAlign.center, style: WebText.button(color: active ? Colors.white : Colors.white54)),
        ),
      ),
    );
  }

  // ── MOBILE LAYOUT (unchanged) ───────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, CartProvider cart, AuthProvider auth, Map<String, List<CartItem>> groupedItems) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: theme.cardColor, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text("Your Cart", style: theme.textTheme.titleMedium),
                ],
              ),
            ),
          ),

          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🛒', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 16),
                        Text('Your cart is empty', style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.go('/'),
                          child: const Text('Browse Restaurants'),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    children: [
                      // Delivery details first (once for all)
                      Text('Delivery Details', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(hintText: 'Recipient Name'),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        _addrTab('Profile', _addressMode == 'profile', () => setState(() => _addressMode = 'profile'), theme),
                        _addrTab('New', _addressMode == 'new', () => setState(() => _addressMode = 'new'), theme),
                      ]),
                      const SizedBox(height: 8),
                      if (_addressMode == 'profile')
                        Text('📍 ${auth.user?.address ?? "Update address in profile"}', style: theme.textTheme.bodySmall)
                      else
                        TextField(controller: _newAddressCtrl, decoration: const InputDecoration(hintText: 'Enter delivery address')),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(),
                      ),

                      // Grouped order sections
                      ...groupedItems.entries.map((entry) {
                        final restId = entry.key;
                        final items = entry.value;
                        final restName = items.first.restaurantName;
                        final subtotal = items.fold(0.0, (sum, i) => sum + i.price * i.quantity);
                        final total = subtotal + 25.0 + _tip; // Using flat 25 birr delivery per restaurant

                        return Container(
                          margin: const EdgeInsets.only(bottom: 30),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(restName, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                              const SizedBox(height: 12),
                              ...items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Text('${item.quantity}x', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(item.name)),
                                    Text('ETB ${(item.price * item.quantity).toStringAsFixed(0)}'),
                                  ],
                                ),
                              )),
                              const Divider(),
                              _summaryRow('Subtotal', 'ETB ${subtotal.toStringAsFixed(0)}', theme),
                              _summaryRow('Delivery', 'ETB 25', theme),
                              _summaryRow('Total', 'ETB ${total.toStringAsFixed(0)}', theme, isTotal: true),
                              const SizedBox(height: 16),
                              
                              Text('Payment for $restName', style: theme.textTheme.titleSmall),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _pickPaymentImage(restId),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _paymentFiles[restId] != null ? AppColors.success : AppColors.primary, width: 2),
                                  ),
                                  child: Center(
                                    child: _uploadingStatus[restId] == true
                                      ? const CircularProgressIndicator()
                                       : Text(
                                          _paymentFiles[restId] != null 
                                            ? '✅ Receipt: ${_paymentFiles[restId]!.name}'
                                            : '📤 Upload Screenshot',
                                          style: TextStyle(color: _paymentFiles[restId] != null ? AppColors.success : AppColors.primary),
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _uploadingStatus[restId] == true ? null : () => _handleCheckout(restId, items, subtotal),
                                  child: Text('Pay & Place Order for $restName'),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _addrTab(String label, bool active, VoidCallback onTap, ThemeData theme) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : theme.cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: active ? Colors.white : theme.colorScheme.onBackground, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, ThemeData theme, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isTotal ? const TextStyle(fontWeight: FontWeight.bold) : null),
          Text(value, style: isTotal ? const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18) : null),
        ],
      ),
    );
  }
}
