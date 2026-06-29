import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/features/home/presentation/widgets/home_bottom_navigation.dart';
import 'package:tmjapp/features/trip_history/data/datasources/trip_history_remote_datasource.dart';
import 'package:tmjapp/features/trip_history/domain/entities/trip_history_item.dart';
import 'package:tmjapp/features/trip_history/presentation/controllers/trip_history_controller.dart';
import 'package:tmjapp/features/trip_history/presentation/pages/trip_detail_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripHistoryPage extends StatefulWidget {
  const TripHistoryPage({super.key});

  @override
  State<TripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage> {
  late final TripHistoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TripHistoryController(
      remoteDataSource: TripHistoryRemoteDataSource(),
    )..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5), // Fundo cinza super claro
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final state = _controller.state;

            return Column(
              children: [
                // Cabeçalho e Abas (Fundo Branco)
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 8, left: 8, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Minhas Viagens',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _TripTab(
                              label: 'Passadas',
                              selected: state.selectedTab == 0,
                              onTap: () => _controller.selectTab(0),
                            ),
                          ),
                          Expanded(
                            child: _TripTab(
                              label: 'Agendadas',
                              selected: state.selectedTab == 1,
                              onTap: () => _controller.selectTab(1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Divisória sutil abaixo das abas
                Container(height: 1, color: const Color(0xFFF1F5F9)),

                // Lista de Histórico
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _controller.refresh,
                    color: const Color(0xFFC92D7A),
                    child: state.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFC92D7A)))
                        : ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              if (state.errorMessage != null)
                                _TripFeedback(
                                  message: state.errorMessage!,
                                  actionLabel: 'Tentar novamente',
                                  onTap: _controller.refresh,
                                )
                              else if (state.visibleTrips.isEmpty)
                                _TripFeedback(
                                  message: state.selectedTab == 0
                                      ? 'Você ainda não tem corridas finalizadas.'
                                      : 'Nenhuma corrida agendada no momento.',
                                )
                              else
                                ...state.visibleTrips.map(
                                  (trip) => _TripHistoryTile(
                                    item: trip,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              TripDetailPage(item: trip),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                              // Texto de Fim de Histórico
                              if (!state.isLoading &&
                                  state.visibleTrips.isNotEmpty)
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 36),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Fim do histórico de 30 dias',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
                HomeBottomNavigation(
                  currentIndex: 1,
                  onTap: (index) => _handleBottomNavigation(context, index),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleBottomNavigation(BuildContext context, int index) {
    debugPrint('TripHistory bottom nav tap -> $index');
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed(AppRoutes.payments);
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
        break;
      default:
        break;
    }
  }
}

class _TripFeedback extends StatelessWidget {
  const _TripFeedback({
    required this.message,
    this.actionLabel,
    this.onTap,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          if (actionLabel != null && onTap != null) ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFC92D7A)),
              child: Text(
                actionLabel!,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TripTab extends StatelessWidget {
  const _TripTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? const Color(0xFFDB2777) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? const Color(0xFFDB2777) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _TripHistoryTile extends StatelessWidget {
  const _TripHistoryTile({
    required this.item,
    required this.onTap,
  });

  final TripHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE CORES DOS STATUS ---
    final statusLower = item.status.toLowerCase();
    final isCanceled = statusLower.contains('cancel');
    final isCompleted =
        statusLower.contains('concluíd') || statusLower.contains('concluid');

    Color statusColor;
    if (isCanceled) {
      statusColor = const Color(0xFFDC2626); // Vermelho para canceladas
    } else if (isCompleted) {
      statusColor = const Color(0xFF059669); // Verde para concluídas
    } else {
      statusColor = const Color(0xFF64748B); // Cinza para pendentes/outras
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
                color: Color(0xFFF1F5F9), width: 1.5), // Fina linha separadora
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- INÍCIO DA ALTERAÇÃO DO MAPA ---
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 58,
                height: 58,
                child: GoogleMap(
                  // Substitua item.latitude e item.longitude pelas propriedades corretas da sua model
                  initialCameraPosition: CameraPosition(
                    target: LatLng(item.latitude, item.longitude),
                    zoom: 15.0,
                  ),
                  liteModeEnabled:
                      true, // Garante que o app não trave ao rolar a lista
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  markers: {
                    Marker(
                      // Pode usar item.id se sua model tiver um identificador único
                      markerId: const MarkerId('trip_marker'),
                      position: LatLng(item.latitude, item.longitude),
                    ),
                  },
                ),
              ),
            ),
            // --- FIM DA ALTERAÇÃO DO MAPA ---

            const SizedBox(width: 14),

            // Textos descritivos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.vehicle} • ${item.plate}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: '${item.dateLabel} • ${item.driverName} • ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                      children: [
                        TextSpan(
                          text: item.status,
                          style: GoogleFonts.plusJakartaSans(
                            color: statusColor, // Cor dinâmica aplicada aqui!
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Valor e Ícone >
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'R\$ ${item.price.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
