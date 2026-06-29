import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_product.dart';

class RideSearchingSheet extends StatelessWidget {
  const RideSearchingSheet({
    super.key,
    required this.origin,
    required this.destination,
    required this.product,
    required this.paymentSummary,
    required this.statusTitle,
    required this.statusDescription,
    required this.driverName,
    required this.driverRating,
    required this.vehicleSummary,
    required this.plate,
    required this.hasRealtimeTracking,
    required this.hasDriverLocation,
    required this.isCancelling,
    required this.canCancel,
    required this.onSOS,
    required this.onCancel,
  });

  final RouteLocation origin;
  final RouteLocation destination;
  final RideProduct product;
  final String paymentSummary;
  final String statusTitle;
  final String statusDescription;
  final String? driverName;
  final double? driverRating;
  final String? vehicleSummary;
  final String? plate;
  final bool hasRealtimeTracking;
  final bool hasDriverLocation;
  final bool isCancelling;
  final bool canCancel;
  final VoidCallback onSOS;
  final Future<void> Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 62,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D5DD),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            statusTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statusDescription,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF98A2B3),
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.22, end: 0.64),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  minHeight: 6,
                  value: value,
                  color: const Color(0xFFC92D7A),
                  backgroundColor: const Color(0xFFF1D8E5),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _LocationLine(
                  label: 'ORIGEM',
                  value: origin.title,
                  icon: Icons.circle,
                  iconColor: const Color(0xFFC92D7A),
                ),
                const SizedBox(height: 14),
                _LocationLine(
                  label: 'DESTINO',
                  value: destination.title,
                  icon: Icons.location_on_rounded,
                  iconColor: const Color(0xFFC92D7A),
                ),
                const Divider(height: 28),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.local_taxi_rounded,
                        color: Color(0xFFC92D7A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF101828),
                            ),
                          ),
                          Text(
                            product.etaLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF98A2B3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'R\$ ${product.estimatedPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFC92D7A),
                          ),
                        ),
                        Text(
                          paymentSummary,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF98A2B3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (driverName != null ||
              vehicleSummary != null ||
              plate != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE7F3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFFC92D7A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (driverName != null)
                          Text(
                            driverName!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF101828),
                            ),
                          ),
                        if (vehicleSummary != null)
                          Text(
                            vehicleSummary!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF667085),
                            ),
                          ),
                        if (plate != null)
                          Text(
                            'Placa $plate',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF475467),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (driverRating != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          driverRating!.toStringAsFixed(1),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF101828),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
          if (hasRealtimeTracking || hasDriverLocation) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                hasDriverLocation
                    ? 'Localizacao do motorista atualizada. Acompanhe a chegada no mapa.'
                    : 'Sessao realtime pronta para acompanhar o motorista.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB42318),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: onSOS,
              icon: const Icon(
                Icons.dangerous,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                'SOS Emergência',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 4,
                shadowColor: const Color(0x44DC2626),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: canCancel ? onCancel : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFECEFF3),
                foregroundColor: const Color(0xFF667085),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: isCancelling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.close_rounded),
              label: Text(
                isCancelling ? 'Cancelando...' : 'Cancelar Solicitação',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF98A2B3),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF344054),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
