import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RideDriverAssignedSheet extends StatelessWidget {
  RideDriverAssignedSheet({
    super.key,
    required this.etaLabel,
    required this.driverName,
    required this.driverRating,
    required this.vehiclePlate,
    required this.vehicleSummary,
    required this.onCall,
    required this.onChat,
    required this.onShare,
    required this.onCancel,
    required this.canCancel,
    this.driverArrived = false,
    this.meetingPointAddress = '',
    this.onConfirmComing,
  })  : assert(!driverArrived || onConfirmComing != null,
            'onConfirmComing é obrigatório quando driverArrived é verdadeiro'),
        assert(!driverArrived || meetingPointAddress.isNotEmpty,
            'meetingPointAddress é obrigatório quando driverArrived é verdadeiro');

  final String etaLabel;
  final String? driverName;
  final double? driverRating;
  final String? vehiclePlate;
  final String? vehicleSummary;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onShare;
  final Future<void> Function() onCancel;
  final bool canCancel;
  final bool driverArrived;
  final String meetingPointAddress;
  final VoidCallback? onConfirmComing;

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
          const SizedBox(height: 16),
          if (driverArrived) ...[
            _DriverArrivedCard(
              driverName: driverName ?? 'Seu motorista',
              vehiclePlate: vehiclePlate ?? 'ABC-1234',
              vehicleSummary: vehicleSummary ?? 'Toyota Corolla Prata',
            ),
            const SizedBox(height: 20),
            _DriverArrivedMeetingPoint(
              meetingPointAddress: meetingPointAddress,
              onMessage: onChat,
              onConfirmComing: onConfirmComing!,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFCE7F3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextButton(
                onPressed: canCancel ? onCancel : null,
                style: TextButton.styleFrom(
                  foregroundColor: canCancel
                      ? const Color(0xFFC92D7A)
                      : const Color(0xFF98A2B3),
                ),
                child: Text(
                  'Cancelar viagem',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Tempo de chegada
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF2F8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  etaLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC92D7A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Informações do Motorista e Veículo
            Row(
              children: [
                // Foto do motorista
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF155E75)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 14),
                // Nome e Avaliação
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
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_border_rounded,
                            size: 16,
                            color: Color(0xFFC92D7A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            driverRating?.toStringAsFixed(1) ?? '4.9',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475467),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('•',
                              style: TextStyle(color: Color(0xFF98A2B3))),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '1.240 viagens',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF667085),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Placa e Modelo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        vehiclePlate ?? 'ABC-1234',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vehicleSummary ?? 'Corolla - Prata',
                        textAlign: TextAlign.center,
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
            const SizedBox(height: 24),
            // Botões de Ação
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
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.phone_outlined,
                    label: 'Ligar',
                    onTap: onCall,
                    isPrimary: true,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 60,
                  child: _ShareButton(onTap: onShare),
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
            const SizedBox(height: 24),
            // Divisor
            Container(height: 1, color: const Color(0xFFF1F5F9)),
            const SizedBox(height: 16),
            // Rodapé do Seguro e Cancelamento
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: Color(0xFF98A2B3),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Viagem protegida por seguro',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF98A2B3),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: canCancel ? onCancel : null,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Cancelar Viagem',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: canCancel
                          ? const Color(0xFFC92D7A)
                          : const Color(0xFF98A2B3),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

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
      height: 56, // Tamanho reduzido para bater com a proporção do Figma
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
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF101828),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFC92D7A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        child: const Icon(Icons.navigation_outlined, size: 22),
      ),
    );
  }
}

class _DriverArrivedCard extends StatelessWidget {
  const _DriverArrivedCard({
    required this.driverName,
    required this.vehiclePlate,
    required this.vehicleSummary,
  });

  final String driverName;
  final String vehiclePlate;
  final String vehicleSummary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFC92D7A), Color(0xFFFB7185)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.motorcycle_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seu motorista chegou!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$driverName está aguardando no portão',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475467),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehiclePlate,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF101828),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              vehicleSummary,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEBF5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'VEÍCULO',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF475467),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverArrivedMeetingPoint extends StatelessWidget {
  const _DriverArrivedMeetingPoint({
    required this.meetingPointAddress,
    required this.onMessage,
    required this.onConfirmComing,
  });

  final String meetingPointAddress;
  final VoidCallback onMessage;
  final VoidCallback onConfirmComing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE7F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFFC92D7A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'PONTO DE ENCONTRO',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF475467),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            meetingPointAddress,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMessage,
                  icon: const Icon(
                    Icons.message_outlined,
                    size: 20,
                    color: Color(0xFF344054),
                  ),
                  label: Text(
                    'Mensagem',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF344054),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onConfirmComing,
                  icon: const Icon(
                    Icons.directions_walk_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Estou indo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFC92D7A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
