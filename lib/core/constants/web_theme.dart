import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Premium web design system — shared tokens, widgets, and helpers
/// Used only on web; mobile layouts remain unaffected.

// ─── Typography ──────────────────────────────────────────────────────────────

class WebText {
  static TextStyle display({Color? color}) => GoogleFonts.outfit(
        fontSize: 52, fontWeight: FontWeight.w900, color: color ?? Colors.white, height: 1.1, letterSpacing: -1.5);

  static TextStyle h1({Color? color}) => GoogleFonts.outfit(
        fontSize: 36, fontWeight: FontWeight.w800, color: color ?? Colors.white, height: 1.2, letterSpacing: -0.5);

  static TextStyle h2({Color? color}) => GoogleFonts.outfit(
        fontSize: 24, fontWeight: FontWeight.w800, color: color ?? Colors.white, height: 1.3);

  static TextStyle h3({Color? color}) => GoogleFonts.outfit(
        fontSize: 18, fontWeight: FontWeight.w700, color: color ?? Colors.white);

  static TextStyle body({Color? color}) => GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w400, color: color ?? Colors.white70, height: 1.6);

  static TextStyle label({Color? color}) => GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w700, color: color ?? Colors.white38, letterSpacing: 1.2);

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w400, color: color ?? Colors.white54);

  static TextStyle button({Color? color}) => GoogleFonts.outfit(
        fontSize: 15, fontWeight: FontWeight.w700, color: color ?? Colors.white);
}

// ─── Colors ──────────────────────────────────────────────────────────────────

class WebColors {
  static const bg = Color(0xFF0C0E14);         // Main page background
  static const surface = Color(0xFF13161E);    // Card / panel background
  static const surfaceElevated = Color(0xFF1A1D2A); // Input / elevated surface
  static const border = Color(0xFF252836);     // Subtle borders
  static const borderHover = Color(0xFF3D4158);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9CA3AF);
  static const textMuted = Color(0xFF4B5563);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
}

// ─── Shared Containers ───────────────────────────────────────────────────────

class WebContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  const WebContainer({
    super.key,
    required this.child,
    this.maxWidth = 1280,
    this.padding = const EdgeInsets.symmetric(horizontal: 48),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

// ─── Premium Input Field ──────────────────────────────────────────────────────

class PremiumInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final bool obscure;
  final TextInputType? keyboardType;
  final int maxLines;

  const PremiumInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixWidget,
    this.obscure = false,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: WebText.label()),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLines: maxLines,
          autocorrect: false,
          style: GoogleFonts.inter(color: WebColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: GoogleFonts.inter(color: WebColors.textMuted, fontSize: 14),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 17, color: WebColors.textMuted)
                : null,
            suffixIcon: suffixWidget,
            filled: true,
            fillColor: WebColors.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: WebColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: WebColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ─── Premium Button ───────────────────────────────────────────────────────────

class PremiumButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final Color? color;
  final IconData? icon;
  final double height;

  const PremiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.color,
    this.icon,
    this.height = 48,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.color ?? AppColors.primary;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.outlined
                ? Colors.transparent
                : (_hovered ? bg.withOpacity(0.85) : bg),
            borderRadius: BorderRadius.circular(10),
            border: widget.outlined ? Border.all(color: bg, width: 1.5) : null,
            boxShadow: widget.outlined || !_hovered
                ? null
                : [BoxShadow(color: bg.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 16, color: widget.outlined ? bg : Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(widget.label,
                          style: WebText.button(
                              color: widget.outlined ? bg : Colors.white)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class WebStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? accentColor;
  final String? subtitle;

  const WebStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: WebColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WebColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (subtitle != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: WebColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(subtitle!,
                      style: GoogleFonts.inter(color: WebColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(value, style: WebText.h1(color: WebColors.textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: WebText.caption()),
        ],
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'pending' || 'placed' => ('Pending', WebColors.warning),
      'preparing' => ('Preparing', const Color(0xFF3B82F6)),
      'delivering' => ('Out for Delivery', AppColors.primary),
      'delivered' => ('Delivered', WebColors.success),
      'cancelled' => ('Cancelled', WebColors.error),
      _ => (status, WebColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: GoogleFonts.inter(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

// ─── Divider ──────────────────────────────────────────────────────────────────

class WebDivider extends StatelessWidget {
  const WebDivider({super.key});

  @override
  Widget build(BuildContext context) => const Divider(color: WebColors.border, thickness: 1, height: 1);
}

// ─── Section Header ───────────────────────────────────────────────────────────

class WebSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const WebSectionHeader({super.key, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: WebText.h2(color: WebColors.textPrimary)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: WebText.caption()),
            ],
          ],
        ),
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }
}
