import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DestinationQuickChip extends StatelessWidget {
  const DestinationQuickChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE3E8EF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFC92D7A), size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF344054),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
