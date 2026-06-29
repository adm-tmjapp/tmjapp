import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';

class RecentDestinationTile extends StatelessWidget {
  const RecentDestinationTile({
    super.key,
    required this.icon,
    required this.location,
    required this.onTap,
  });

  final IconData icon;
  final RouteLocation location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, color: const Color(0xFF98A2B3)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1D2939),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location.subtitle.isEmpty ? location.title : location.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF98A2B3),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFD0D5DD),
            ),
          ],
        ),
      ),
    );
  }
}
