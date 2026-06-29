import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFC72F79),
                Color(0xFFE04095),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33C72F79),
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
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: const Color(0xFF1F2937),
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
        const SizedBox(height: 6),
        Text(
          'Premium Experience',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF9CA3AF),
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}
