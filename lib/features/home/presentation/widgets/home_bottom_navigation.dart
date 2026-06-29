import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'Inicio'),
      (Icons.route_rounded, 'Viagens'),
      (Icons.account_balance_wallet_rounded, 'Carteira'),
      (Icons.person_rounded, 'Perfil'),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;
              final color = isSelected
                  ? const Color(0xFFC92D7A)
                  : const Color(0xFF9FA6B2);

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onTap(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.$1, color: color, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          item.$2,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
