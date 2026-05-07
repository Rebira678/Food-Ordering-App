import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// On web (wide screen): centers the child in a constrained-width column
/// with an optional max width and a styled background. On mobile: pass-through.
class WebPageWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const WebPageWrapper({
    super.key,
    required this.child,
    this.maxWidth = 480,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    final screenWidth = MediaQuery.of(context).size.width;

    // On narrow web (< 600px), behave like mobile
    if (screenWidth < 600) return child;

    // On wide web: center the mobile-width content with a decorative surround
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D13),
      body: Center(
        child: Container(
          width: maxWidth,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRect(child: child),
        ),
      ),
    );
  }
}
