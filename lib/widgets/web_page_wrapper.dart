import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// On web wide screens: provides a full-width container (real website feel).
/// On mobile: transparent pass-through, zero changes.
class WebPageWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const WebPageWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1280,
  });

  @override
  Widget build(BuildContext context) {
    // On mobile or narrow web: show as-is
    if (!kIsWeb) return child;
    return child; // web shells handle their own layout
  }
}
