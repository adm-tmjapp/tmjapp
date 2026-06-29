import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RideFinishedSheet extends StatelessWidget {
  const RideFinishedSheet({
    super.key,
    required this.originTitle,
    required this.destinationTitle,
    required this.driverName,
    required this.finalPrice,
    required this.paymentMethod,
    required this.onFinish,
    this.onClearActiveRide,
  });

  final String originTitle;
  final String destinationTitle;
  final String? driverName;
  final double finalPrice;
  final String paymentMethod;
  final VoidCallback onFinish;
  final VoidCallback? onClearActiveRide;

  @override
  Widget build(BuildContext context) {
    final driverFirstName = (driverName ?? 'o motorista').split(' ').first;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título no topo superior esquerdo
          Text(
            'Viagem Finalizada',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),

          // --- CARD RESUMO ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF9FAFB)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'VALOR TOTAL PAGO',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF98A2B3),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'R\$ ${finalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFFC92D7A), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      paymentMethod,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFC92D7A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(height: 1, color: const Color(0xFFF1F5F9)),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _RouteDetailColumn(label: 'DISTÂNCIA', value: '6.2 km'),
                    _RouteDetailColumn(label: 'TEMPO', value: '14 min'),
                  ],
                ),
                const SizedBox(height: 18),
                _RoutePoint(
                    label: 'ORIGEM', value: originTitle, isFilled: false),
                _RoutePoint(
                    label: 'DESTINO', value: destinationTitle, isFilled: true),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- CARD DE AVALIAÇÃO ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F766E), Color(0xFF155E75)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverName ?? 'João Santos',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF101828),
                            ),
                          ),
                          Text(
                            'Toyota Corolla • Prata • ABC-1234',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Como foi sua experiência com $driverFirstName?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(Icons.star_outline_rounded,
                          color: Color(0xFFC92D7A), size: 36),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- BOTÃO CONCLUIR ---
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                onClearActiveRide?.call();
                onFinish();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC92D7A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              child: Text(
                'CONCLUIR',
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

// --- SUB-WIDGETS (CLASSES AUXILIARES) ---

class _RouteDetailColumn extends StatelessWidget {
  const _RouteDetailColumn({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF98A2B3),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint(
      {required this.label, required this.value, required this.isFilled});
  final String label;
  final String value;
  final bool isFilled;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.circle, color: Color(0xFFC92D7A), size: 14),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF98A2B3),
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF344054),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isFilled)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Container(
              width: 2,
              height: 16,
              color: const Color(0xFFE4E7EC),
            ),
          ),
      ],
    );
  }
}
