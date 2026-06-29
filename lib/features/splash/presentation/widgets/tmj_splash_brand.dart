import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TmjSplashBrand extends StatelessWidget {
  const TmjSplashBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: const Color(0xFFC72F79),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'TMJ',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
            ),
          ),
        ),
        const SizedBox(height: 22),
        RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF171B2D),
              letterSpacing: -0.8,
            ),
            children: const [
              TextSpan(text: 'TMJ'),
              TextSpan(
                text: 'App',
                style: TextStyle(color: Color(0xFFC72F79)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'PREMIUM EXPERIENCE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFB6BAC4),
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}
