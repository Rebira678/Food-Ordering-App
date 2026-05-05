import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../models/cart_item.dart';
import '../../core/constants/app_colors.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
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
  double _tip = 0;
  
  // Track files for each restaurant to allow separate payments
  final Map<String, File?> _paymentFiles = {};
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
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
              const SizedBox(height: 20),
              Text('Order Sent!',
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(
                'Your order has been successfully sent to $restaurantName.\nYou will be notified when it\'s being prepared.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
    final file = await ImageService.pickImage();
    if (file != null) {
      setState(() => _paymentFiles[restaurantId] = file);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();
    final auth = context.read<AuthProvider>();

    // Group items by restaurant
    final Map<String, List<CartItem>> groupedItems = {};
    for (var item in cart.items) {
      groupedItems.putIfAbsent(item.restaurantId, () => []).add(item);
    }

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
                                            ? '✅ Receipt: ${p.basename(_paymentFiles[restId]!.path)}'
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
