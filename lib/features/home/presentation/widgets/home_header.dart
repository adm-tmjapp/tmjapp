import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/features/home/domain/entities/home_profile.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.profile,
    required this.onNotificationTap,
    this.currentTime,
  });

  final HomeProfile profile;
  final VoidCallback onNotificationTap;
  final DateTime? currentTime;

  String get _greetingByTime {
    final hour = (currentTime ?? DateTime.now()).hour;
    if (hour < 12) {
      return 'Bom dia!';
    }
    if (hour < 18) {
      return 'Boa tarde!';
    }
    return 'Boa noite!';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFF7D7E7),
          child: Text(
            profile.initials,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFC92D7A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ola, ${profile.firstName}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB0B8C5),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _greetingByTime,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(18),
          ),
          child: IconButton(
            onPressed: onNotificationTap,
            icon: const Icon(
              Icons.notifications_rounded,
              color: Color(0xFF344054),
            ),
          ),
        ),
      ],
    );
  }
}
