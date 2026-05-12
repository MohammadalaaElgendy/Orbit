import 'package:flutter/material.dart';

class TopPadding extends StatelessWidget {
  const TopPadding({super.key});

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    // On Desktop/Tablet, ResponsiveScaffold handles headers natively.
    if (!isMobile) return const SizedBox(height: 0);

    // Exact height match with ResponsiveScaffold mobile AppBar (kToolbarHeight + topPadding + 10)
    // to start content exactly at the edge of the glass effect.
    return SizedBox(
      height: kToolbarHeight + topPadding - 30,
    );
  }
}

class BottomPadding extends StatelessWidget {
  const BottomPadding({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    if (!isMobile) return const SizedBox(height: 40);

    // Matches the height and safe area of the floating bottom nav
    return SizedBox(height: 86 + safeAreaBottom);
  }
}
