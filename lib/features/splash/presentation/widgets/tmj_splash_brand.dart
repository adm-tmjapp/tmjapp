import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _tmjPink = Color(0xFFC72F79);
const _tmjNavy = Color(0xFF111A2E);
const _taglineGrey = Color(0xFF929AAA);

class TmjSplashBrand extends StatelessWidget {
  const TmjSplashBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final logoSize = (constraints.maxWidth * 0.56).clamp(132.0, 184.0);
        final wordmarkSize = (constraints.maxWidth * 0.145).clamp(34.0, 48.0);

        return Semantics(
          container: true,
          label: 'TMJApp, Premium Experience',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: logoSize,
                height: logoSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _tmjPink,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F111A2E),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Text(
                  'TMJ',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: logoSize * 0.34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -logoSize * 0.025,
                  ),
                ),
              ),
              const SizedBox(height: 38),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text.rich(
                  const TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'TMJ',
                        style: TextStyle(color: _tmjNavy),
                      ),
                      TextSpan(
                        text: 'App',
                        style: TextStyle(color: _tmjPink),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: wordmarkSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -wordmarkSize * 0.045,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: constraints.maxWidth,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'PREMIUM EXPERIENCE',
                    maxLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                      color: _taglineGrey,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
