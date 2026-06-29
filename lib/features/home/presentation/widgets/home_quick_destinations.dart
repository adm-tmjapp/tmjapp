import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeQuickDestinations extends StatelessWidget {
  const HomeQuickDestinations({
    super.key,
    required this.onTap,
  });

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_filled, 'Casa'),
      (Icons.work_rounded, 'Trabalho'),
      (Icons.flight_takeoff_rounded, 'Academia'),
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onTap(item.$2),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0E5EC)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(item.$1, color: const Color(0xFFC92D7A), size: 18),
                  const SizedBox(width: 10),
                  Text(
                    item.$2,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
