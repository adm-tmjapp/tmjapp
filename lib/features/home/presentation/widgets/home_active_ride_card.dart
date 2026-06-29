import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/features/home/domain/entities/home_active_ride.dart';

class HomeActiveRideCard extends StatelessWidget {
  const HomeActiveRideCard({
    super.key,
    required this.activeRide,
    required this.onTap,
  });

  final HomeActiveRide activeRide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(27),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF98A2B3),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeRide.driverName?.trim().isNotEmpty == true
                            ? activeRide.driverName!
                            : 'Motorista parceiro',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeRide.vehicleSummary ?? 'Veiculo a caminho',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFC92D7A),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activeRide.driverRating?.toStringAsFixed(1) ?? '5.0',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFC92D7A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeRide.statusLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF98A2B3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.navigation_rounded, size: 22),
                label: Text(
                  'VOLTAR PARA A CORRIDA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC92D7A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
