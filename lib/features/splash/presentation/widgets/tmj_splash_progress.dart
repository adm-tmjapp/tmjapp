import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TmjSplashProgress extends StatelessWidget {
  const TmjSplashProgress({
    super.key,
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);
    final progressValue = (normalizedProgress * 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$progressValue%',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFC72F79),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: normalizedProgress,
            minHeight: 4,
            backgroundColor: const Color(0xFFF2DCE8),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFFC72F79),
            ),
          ),
        ),
      ],
    );
  }
}
