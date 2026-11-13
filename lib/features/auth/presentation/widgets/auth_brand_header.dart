import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/branding/app_icon_passenger.png',
          width: 112,
          height: 112,
          fit: BoxFit.contain,
          semanticLabel: 'Logo TMJApp passageiro',
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
