import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/features/destination_search/domain/entities/place_suggestion.dart';

class PlaceSuggestionTile extends StatelessWidget {
  const PlaceSuggestionTile({
    super.key,
    required this.suggestion,
    required this.onTap,
  });

  final PlaceSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFFC92D7A),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
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
                    suggestion.subtitle,
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
          ],
        ),
      ),
    );
  }
}
