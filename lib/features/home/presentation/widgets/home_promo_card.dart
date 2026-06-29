import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePromoCard extends StatelessWidget {
  const HomePromoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFDF3B8B),
            Color(0xFFC92D7A),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33C92D7A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.local_offer_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ganhe 20% de desconto',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Indique um amigo hoje',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
