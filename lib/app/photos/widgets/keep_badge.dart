import 'package:flutter/material.dart';

/// Teal "KEEP" badge shown on the best/kept copy in a duplicate set.
class KeepBadge extends StatelessWidget {
  const KeepBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF18D0B8),
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: const Text(
        'KEEP',
        style: TextStyle(
          color: Color(0xFF062322),
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
