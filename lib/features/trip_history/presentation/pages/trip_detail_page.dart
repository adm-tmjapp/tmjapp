import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/features/trip_history/domain/entities/trip_history_item.dart';

String buildTripReceiptText(TripHistoryItem item) {
  final price = item.price.toStringAsFixed(2).replaceAll('.', ',');

  return '''Recibo de viagem - TMJ

Viagem: ${item.title}
Data: ${item.dateLabel}
Status: ${item.status}

Origem: ${item.originTitle} - ${item.originSubtitle}
Destino: ${item.destinationTitle} - ${item.destinationSubtitle}

Motorista: ${item.driverName}
Veículo: ${item.vehicle} - ${item.plate}
Distância: ${item.distanceLabel}
Duração: ${item.durationLabel}

Pagamento: ${item.paymentLabel}
Total: R\$ $price
Código da viagem: ${item.id}''';
}

class TripDetailPage extends StatelessWidget {
  const TripDetailPage({
    super.key,
    required this.item,
  });

  final TripHistoryItem item;

  Future<void> _shareReceipt(BuildContext context) async {
    final renderObject = context.findRenderObject();
    final box = renderObject is RenderBox ? renderObject : null;
    final origin =
        box == null ? null : box.localToGlobal(Offset.zero) & box.size;

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: buildTripReceiptText(item),
          subject: 'Recibo da viagem ${item.id}',
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível compartilhar o recibo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lógica para definir a cor baseada no status
    final isCanceled = item.status.toLowerCase().contains('cancelad') ||
        item.status.toLowerCase().contains('cancel');

    final statusBgColor =
        isCanceled ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7);
    final statusTextColor =
        isCanceled ? const Color(0xFFDC2626) : const Color(0xFF16A34A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF334155), size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Detalhes da Viagem',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Container do Google Maps
            Container(
              height: 200,
              width: double.infinity,
              color: const Color(
                  0xFFD6E4D1), // Cor de fundo caso o mapa demore a carregar
              child: const GoogleMap(
                initialCameraPosition: CameraPosition(
                  // Usando valores genéricos para exemplificar. No cenário real,
                  // você deve passar as coordenadas (LatLng) oriundas do `item`.
                  target: LatLng(-23.561684, -46.655981),
                  zoom: 14,
                ),
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                // Aqui você pode adicionar as polylines e marcadores extraindo do item
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.dateLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'R\$ ${item.price.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.status,
                          style: GoogleFonts.plusJakartaSans(
                            color: statusTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _Metric(label: 'DISTÂNCIA', value: item.distanceLabel),
                      const SizedBox(width: 48),
                      _Metric(label: 'DURAÇÃO', value: item.durationLabel),
                    ],
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _DriverCard(item: item),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _RouteCard(item: item),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAGAMENTO',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PaymentDetailCard(item: item),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        AppRoutes.helpSupport,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC92D7A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Ajuda e Suporte',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Builder(
                      builder: (shareContext) => TextButton(
                        onPressed: () => _shareReceipt(shareContext),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                        ),
                        child: Text(
                          'Compartilhar recibo',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.item});
  final TripHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  // Substituir pelo avatar real do motorista quando houver na API
                  image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: -4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.rating.toStringAsFixed(1),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFF59E0B), size: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.driverName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.vehicle} • ${item.plate}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          ),
          child: const Icon(Icons.chat_bubble_outline_rounded,
              color: Color(0xFFC92D7A), size: 16),
        ),
      ],
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.item});
  final TripHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RouteLine(
          label: 'ORIGEM',
          title: item.originTitle,
          subtitle: item.originSubtitle,
          isDestination: false,
        ),
        _RouteLine(
          label: 'DESTINO',
          title: item.destinationTitle,
          subtitle: item.destinationSubtitle,
          isDestination: true,
        ),
      ],
    );
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.isDestination,
  });

  final String label;
  final String title;
  final String subtitle;
  final bool isDestination;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: isDestination ? BoxShape.rectangle : BoxShape.circle,
                    border: isDestination
                        ? null
                        : Border.all(color: const Color(0xFFC92D7A), width: 2),
                    color:
                        isDestination ? const Color(0xFFC92D7A) : Colors.white,
                  ),
                ),
                if (!isDestination)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: const Color(0xFFE2E8F0),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isDestination ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFC92D7A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentDetailCard extends StatelessWidget {
  const _PaymentDetailCard({required this.item});
  final TripHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(4),
          ),
          // Placeholder simples simulando o logo de cartão da imagem
          child: Text(
            'VISA',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.paymentLabel, // Deveria ser "Cartão de Crédito"
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                '•••• 1234', // Mockado para refletir a imagem. Ajustar se a API prover final do cartão.
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Text(
          'R\$ ${item.price.toStringAsFixed(2).replaceAll('.', ',')}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
