import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RideInProgressSheet extends StatelessWidget {
  const RideInProgressSheet({
    super.key,
    required this.etaLabel,
    required this.driverName,
    required this.driverRating,
    required this.vehiclePlate,
    required this.vehicleSummary,
    required this.onCall,
    required this.onChat,
    required this.onShare,
  });

  final String etaLabel;
  final String? driverName;
  final double? driverRating;
  final String? vehiclePlate;
  final String? vehicleSummary;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
          // Pílula superior (arrastador)
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Row principal com Foto, Informações e Tempo
          Row(
            crossAxisAlignment: CrossAxisAlignment
                .center, // Mantém a foto centralizada com os textos
            children: [
              // Foto com Nota Sobreposta
              SizedBox(
                width: 64,
                height: 72,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E293B),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    // Nota (4.9)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFF59E0B), size: 14),
                            const SizedBox(width: 2),
                            Text(
                              driverRating?.toStringAsFixed(1) ?? '4.9',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF101828),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Bloco de Textos (Motorista + Tempo alinhados pelo topo)
              Expanded(
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Alinha "Nome" e "TEMPO"
                  children: [
                    // Textos: Nome, Modelo e Placa
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (driverName ?? '').trim().isNotEmpty
                                ? driverName!
                                : 'João Santos',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF101828),
                              height: 1.2, // Ajuste fino da altura da linha
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${vehicleSummary ?? 'Toyota Corolla'} • Prata',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF667085),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vehiclePlate ?? 'ABC-1234',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF98A2B3),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                        width: 12), // Respiro entre os dados do carro e o tempo

                    // Bloco de Tempo (ETA) na direita
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TEMPO',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF98A2B3),
                            letterSpacing: 0.5,
                            height:
                                1.2, // Força a alinhar perfeitamente com o nome
                          ),
                        ),
                        Text(
                          etaLabel, // Ex: "8 min"
                          textAlign: TextAlign.right,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize:
                                12, // Reduzido levemente para caber textos maiores sem quebrar
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFC92D7A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Botões de Chat e Ligar
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Chat',
                  onTap: onChat,
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ActionButton(
                  icon: Icons.phone_outlined,
                  label: 'Ligar',
                  onTap: onCall,
                  isPrimary: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Botão Compartilhar Viagem Centralizado
          Center(
            child: TextButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share_outlined,
                  size: 20, color: Color(0xFF667085)),
              label: Text(
                'Compartilhar Viagem',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF667085),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sub-widget reutilizável para os botões Chat e Ligar
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 20,
          color: isPrimary ? Colors.white : const Color(0xFFC92D7A),
        ),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          backgroundColor: isPrimary ? const Color(0xFFC92D7A) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFFC92D7A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: Color(0xFFC92D7A)),
          ),
        ),
      ),
    );
  }
}
