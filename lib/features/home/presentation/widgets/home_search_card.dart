import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeSearchCard extends StatelessWidget {
  const HomeSearchCard({
    super.key,
    required this.onTap,
    required this.isBusy,
  });

  final VoidCallback onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: isBusy ? null : onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF0E6ED)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: Color(0xFFC92D7A),
                size: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  isBusy ? 'Montando sua rota...' : 'Para onde vamos?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF98A2B3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
