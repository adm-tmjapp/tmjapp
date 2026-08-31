import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/features/destination_search/domain/entities/destination_search_result.dart';
import 'package:tmjapp/features/destination_search/presentation/pages/destination_search_page.dart';
import 'package:tmjapp/features/favorites/presentation/add_favorite_page.dart';
import 'package:tmjapp/features/home/data/datasources/home_local_datasource.dart';
import 'package:tmjapp/features/home/data/datasources/home_remote_datasource.dart';
import 'package:tmjapp/features/home/data/repositories/home_repository_impl.dart';
import 'package:tmjapp/features/home/domain/entities/home_location.dart';
import 'package:tmjapp/features/home/domain/usecases/build_trip_preview_usecase.dart';
import 'package:tmjapp/features/home/domain/usecases/load_home_data_usecase.dart';
import 'package:tmjapp/features/home/presentation/controllers/home_controller.dart';
import 'package:tmjapp/features/home/presentation/widgets/home_active_ride_card.dart';
import 'package:tmjapp/features/home/presentation/widgets/home_ride_continuation_card.dart';
import 'package:tmjapp/features/ride_request/data/datasources/ride_confirmation_draft_local_datasource.dart';
import 'package:tmjapp/features/ride_request/presentation/services/ride_background_notification.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_request_args.dart';
import 'package:tmjapp/features/ride_request/presentation/pages/ride_request_page.dart';
import 'package:tmjapp/screens/dashboard/notifications_screen.dart';
import 'package:tmjapp/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:tmjapp/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:tmjapp/features/profile/presentation/controllers/profile_controller.dart';
import 'package:tmjapp/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:tmjapp/features/profile/domain/entities/profile_details.dart';
import 'package:tmjapp/features/home/presentation/widgets/peding_payment_page.dart';

// Constantes de cores baseadas no layout da imagem
const Color _primaryPink = Color(0xFFC92D7A);
const Color _textDark = Color(0xFF1D2939);
const Color _textLight = Color(0xFF667085);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  late final HomeController _controller;
  late final TextEditingController _fromController;
  late final TextEditingController _toController;
  GoogleMapController? _mapController;
  final RideConfirmationDraftLocalDataSource _draftLocalDataSource =
      RideConfirmationDraftLocalDataSource();
  final RideBackgroundNotification _backgroundNotification =
      RideBackgroundNotification();
  RideRequestArgs? _confirmationDraft;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fromController = TextEditingController();
    _toController = TextEditingController();

    final repository = HomeRepositoryImpl(
      localDataSource: HomeLocalDataSource(),
      remoteDataSource: HomeRemoteDataSource(),
    );

    _controller = HomeController(
      loadHomeDataUseCase: LoadHomeDataUseCase(repository),
      buildTripPreviewUseCase: BuildTripPreviewUseCase(repository),
    )..initialize();
    _loadConfirmationDraft();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    _controller.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _backgroundNotification.cancel();
      _controller.initialize();
      _loadConfirmationDraft();
    } else if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden) &&
        ModalRoute.of(context)?.isCurrent == true) {
      final activeRide = _controller.state.activeRide;
      if (activeRide != null) {
        _backgroundNotification.show(
          title: activeRide.statusLabel,
          message: 'Toque para voltar ao acompanhamento da corrida.',
        );
      } else if (_confirmationDraft != null) {
        _backgroundNotification.show(
          title: 'Continue sua corrida',
          message: 'Toque para escolher o veículo e confirmar a solicitação.',
        );
      }
    }
  }

  Future<void> _loadConfirmationDraft() async {
    final draft = await _draftLocalDataSource.load();
    if (!mounted) return;
    setState(() => _confirmationDraft = draft);
  }

  // --- MÉTODOS DE LÓGICA MANTIDOS INTACTOS ---

  Future<void> _openTripPlanner({String? presetLabel}) async {
    if (_controller.state.currentLocation == null) {
      await _showLocationAlert(
        _controller.state.errorMessage ??
            'Não foi possível acessar sua localização atual. Ative o serviço de localização e conceda permissão para o app continuar.',
      );
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final result = await navigator.push<DestinationSearchResult>(
      MaterialPageRoute(
        builder: (_) => const DestinationSearchPage(),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    final origin = HomeLocation(
      latitude: result.origin.latitude,
      longitude: result.origin.longitude,
    );
    final destination = HomeLocation(
      latitude: result.destination.latitude,
      longitude: result.destination.longitude,
    );

    _fromController.text = result.origin.title;
    _toController.text = result.destination.title;

    await _controller.previewTrip(origin: origin, destination: destination);

    if (!mounted) {
      return;
    }

    final routePoints = List<HomeLocation>.from(_controller.state.routePoints);
    if (routePoints.isEmpty) {
      return;
    }

    final currentLocation = _controller.state.currentLocation;
    if (_mapController != null && currentLocation != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              currentLocation.latitude < destination.latitude
                  ? currentLocation.latitude
                  : destination.latitude,
              currentLocation.longitude < destination.longitude
                  ? currentLocation.longitude
                  : destination.longitude,
            ),
            northeast: LatLng(
              currentLocation.latitude > destination.latitude
                  ? currentLocation.latitude
                  : destination.latitude,
              currentLocation.longitude > destination.longitude
                  ? currentLocation.longitude
                  : destination.longitude,
            ),
          ),
          80,
        ),
      );
    }

    final userId = _controller.state.profile.userId;
    if (userId.trim().isEmpty) {
      if (!mounted) {
        return;
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
              content:
                  Text('Usuário não identificado para solicitar a corrida.')),
        );
      return;
    }

    await navigator.push(
      MaterialPageRoute(
        builder: (_) => RideRequestPage(
          args: RideRequestArgs(
            userId: userId,
            origin: result.origin,
            destination: result.destination,
            routePoints: routePoints,
          ),
          onClearActiveRide: _controller.clearActiveRide,
        ),
      ),
    );
    if (mounted) {
      await _loadConfirmationDraft();
    }
    _controller.clearTripPreview();
    if (mounted) {
      await _controller.initialize();
    }

    if (presetLabel != null && mounted) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Destino $presetLabel preparado para você.')),
        );
    }
  }

  Future<void> _openAddFavoriteAddress(String label) async {
    final didSave = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddFavoriteAddressPage(initialLabel: label),
      ),
    );
    if (!mounted || didSave != true) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Endereço de $label atualizado.')),
      );
  }

  Future<void> _resumeActiveRide() async {
    final activeRide = _controller.state.activeRide;
    if (activeRide == null) {
      return;
    }

    final origin = HomeLocation(
      latitude: activeRide.origin.latitude,
      longitude: activeRide.origin.longitude,
    );
    final destination = HomeLocation(
      latitude: activeRide.destination.latitude,
      longitude: activeRide.destination.longitude,
    );

    await _controller.previewTrip(origin: origin, destination: destination);
    if (!mounted) {
      return;
    }

    final routePoints = List<HomeLocation>.from(_controller.state.routePoints);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RideRequestPage(
          args: RideRequestArgs(
            userId: _controller.state.profile.userId,
            origin: activeRide.origin,
            destination: activeRide.destination,
            routePoints: routePoints,
            existingRideId: activeRide.rideId,
            existingRideStatus: activeRide.status,
            initialProduct: activeRide.product,
            initialPaymentMethodLabel: activeRide.paymentMethodLabel,
          ),
          onClearActiveRide: _controller.clearActiveRide,
        ),
      ),
    );
    _controller.clearTripPreview();
    if (!mounted) return;
    await _controller.initialize();
  }

  Future<void> _resumeConfirmationDraft() async {
    final draft = _confirmationDraft;
    if (draft == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RideRequestPage(args: draft),
      ),
    );
    if (!mounted) return;
    await _loadConfirmationDraft();
    if (!mounted) return;
    await _controller.initialize();
  }

  Future<void> _showLocationAlert(String message) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Localização indisponível'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendi'),
            ),
          ],
        );
      },
    );
  }

  Set<Marker> _buildMarkers() {
    final state = _controller.state;
    final markers = <Marker>{};

    final currentLocation = state.currentLocation;
    if (currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current-location'),
          position: LatLng(currentLocation.latitude, currentLocation.longitude),
          infoWindow: const InfoWindow(title: 'Você está aqui'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    for (final driver in state.drivers) {
      markers.add(
        Marker(
          markerId: MarkerId(driver.id),
          position: LatLng(
            driver.location.latitude,
            driver.location.longitude,
          ),
          infoWindow: InfoWindow(title: driver.name),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    final points = _controller.state.routePoints;
    if (points.isEmpty) {
      return const {};
    }

    return {
      Polyline(
        polylineId: const PolylineId('trip-preview'),
        color: _primaryPink,
        width: 5,
        points: points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(),
      ),
    };
  }

  void _handleBottomNavigation(int index) {
    switch (index) {
      case 1:
        Navigator.of(context).pushReplacementNamed(AppRoutes.tripHistory);
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

  // --- INTERFACE (LAYOUT) ---

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 360 ? 12.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _CustomBottomNavBar(
        currentIndex: 0,
        onTap: _handleBottomNavigation,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final state = _controller.state;
          final currentLocation = state.currentLocation;

          // AQUI: Simulando a variável de dívida.
          // Troque pelo valor real vindo do seu state, por exemplo: state.pendingDebt
          const double? pendingDebt = // Local de teste para saldo devedor
              null; // Defina como null quando não houver dívida

          return Stack(
            children: [
              // 1. MAPA
              Positioned.fill(
                child: state.isLoading || currentLocation == null
                    ? const Center(
                        child: CircularProgressIndicator(color: _primaryPink))
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            currentLocation.latitude,
                            currentLocation.longitude,
                          ),
                          zoom: 13.8,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        compassEnabled: false,
                        markers: _buildMarkers(),
                        polylines: _buildPolylines(),
                      ),
              ),

              // 2. GRADIENTES PARA SUAVIZAR O MAPA (Efeito esfumaçado)
              Positioned.fill(
                child: IgnorePointer(
                  child: Column(
                    children: [
                      // Gradiente superior (branco -> transparente)
                      Container(
                        height: 240,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 1.0),
                              Colors.white.withValues(alpha: 0.9),
                              Colors.white.withValues(alpha: 0.5),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: const [0.3, 0.6, 0.85, 1.0],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Gradiente inferior (transparente -> branco)
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.white.withValues(alpha: 1.0),
                              Colors.white.withValues(alpha: 0.9),
                              Colors.white.withValues(alpha: 0.3),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: const [0.2, 0.5, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. CONTEÚDO SUPERIOR (Header, Pesquisa, Destinos Rápidos)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopHeader(
                          userName: state.profile.name,
                          onAvatarTap: () {
                            final profileController = ProfileController(
                              localDataSource: ProfileLocalDataSource(),
                              remoteDataSource: ProfileRemoteDataSource(),
                            )..initialize();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangeNotifierProvider.value(
                                  value: profileController,
                                  child: ProfileEditPage(
                                    profile: ProfileDetails(
                                      userId: state.profile.userId,
                                      name: state.profile.name,
                                      email: '',
                                      phone: '',
                                      profilePhotoUrl: '',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          onNotificationTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => NotificationScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        if (state.activeRide != null)
                          HomeActiveRideCard(
                            activeRide: state.activeRide!,
                            onTap: _resumeActiveRide,
                          )
                        else if (_confirmationDraft != null)
                          HomeRideContinuationCard(
                            draft: _confirmationDraft!,
                            onTap: _resumeConfirmationDraft,
                          )
                        else ...[
                          _SearchBar(onTap: _openTripPlanner),

                          // Localize este trecho dentro da build do seu DashboardPage:
                          if (pendingDebt != null && pendingDebt > 0)
                            _PendingDebtCard(
                              amount: pendingDebt,
                              onTap: () {
                                // AQUI: Navegue para a nova tela passando o valor da dívida
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PendingPaymentPage(
                                        debtAmount: pendingDebt),
                                  ),
                                );
                              },
                            ),

                          const SizedBox(height: 18),
                          _QuickDestinationsRow(
                            onTap: _openAddFavoriteAddress,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // 4. CONTROLES DO MAPA (Direita)
              Positioned(
                right: horizontalPadding,
                bottom: state.activeRide == null ? 112 : 16,
                child: Column(
                  children: [
                    _MapZoomControls(
                      onZoomIn: () =>
                          _mapController?.animateCamera(CameraUpdate.zoomIn()),
                      onZoomOut: () =>
                          _mapController?.animateCamera(CameraUpdate.zoomOut()),
                    ),
                    const SizedBox(height: 12),
                    // Botão de localização (mantido para não perder funcionalidade)
                    _MapLocationButton(
                      onTap: () {
                        if (currentLocation == null || _mapController == null) {
                          return;
                        }
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLng(
                            LatLng(currentLocation.latitude,
                                currentLocation.longitude),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 5. CARD PROMOCIONAL
              if (state.activeRide == null)
                Positioned(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  bottom: 16,
                  child: _PromoCard(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(AppRoutes.promotionsAndCoupons);
                    },
                  ),
                ),

              // 6. MENSAGEM DE ERRO (Se houver)
              if (state.errorMessage != null && state.errorMessage!.isNotEmpty)
                Positioned(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  bottom: state.activeRide == null ? 112 : 16,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F1D1D),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// WIDGETS PRIVADOS QUE CONSTROEM O LAYOUT
// ============================================================================

class _TopHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onAvatarTap;
  final String userName;

  const _TopHeader({
    required this.onNotificationTap,
    required this.onAvatarTap,
    required this.userName,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Bom dia!';
    } else if (hour >= 12 && hour < 18) {
      return 'Boa tarde!';
    } else {
      return 'Boa noite!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstName = userName.trim().isNotEmpty
        ? userName.trim().split(' ').first.toUpperCase()
        : 'USUÁRIO';

    return Row(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8F1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.person, color: _primaryPink, size: 28),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OLÁ, $firstName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _textLight,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getGreeting(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded,
                  color: _textDark, size: 28),
              onPressed: onNotificationTap,
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _primaryPink,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: _primaryPink, size: 26),
            const SizedBox(width: 14),
            Text(
              'Para onde vamos?',
              style: TextStyle(
                color: _textLight.withValues(alpha: 0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickDestinationsRow extends StatelessWidget {
  final Function(String) onTap;

  const _QuickDestinationsRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _QuickDestPill(
          icon: Icons.home_outlined,
          label: 'Casa',
          onTap: () => onTap('Casa'),
        ),
        _QuickDestPill(
          icon: Icons.work_outline,
          label: 'Trabalho',
          onTap: () => onTap('Trabalho'),
        ),
        _QuickDestPill(
          icon: Icons.fitness_center_outlined,
          label: 'Academia',
          onTap: () => onTap('Academia'),
        ),
      ],
    );
  }
}

class _QuickDestPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickDestPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: _primaryPink, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: _textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _MapZoomControls({required this.onZoomIn, required this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: _textDark, size: 22),
            onPressed: onZoomIn,
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          IconButton(
            icon: const Icon(Icons.remove, color: _textDark, size: 22),
            onPressed: onZoomOut,
          ),
        ],
      ),
    );
  }
}

class _MapLocationButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MapLocationButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child:
            const Icon(Icons.my_location_rounded, color: _textDark, size: 22),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final VoidCallback onTap;

  const _PromoCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFCE2A7B), Color(0xFFB52166)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primaryPink.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_offer_outlined,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Ganhe 20% de desconto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Indique um amigo hoje',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _CustomBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _BottomNavItem(
              icon: Icons.directions_car_rounded,
              label: 'INÍCIO',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              icon: Icons.history_rounded,
              label: 'VIAGENS',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'CARTEIRA',
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              icon: Icons.person_outline_rounded,
              label: 'PERFIL',
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? _primaryPink : _textLight.withValues(alpha: 0.6),
            size: 26,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color:
                  isActive ? _primaryPink : _textLight.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// 👇 AQUI ESTÁ O NOVO WIDGET ADICIONADO 👇
class _PendingDebtCard extends StatelessWidget {
  final double amount;
  final VoidCallback onTap;

  const _PendingDebtCard({
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Formata o valor para o padrão brasileiro
    final formattedAmount =
        'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}';

    return Container(
      // A margem superior empurra o card para baixo da barra de pesquisa
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8F1), // Fundo rosa clarinho
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryPink.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          // Ícone da carteira
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primaryPink.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: _primaryPink,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conclua o pagamento',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700, // Texto em negrito
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedAmount,
                  style: const TextStyle(
                    color: _primaryPink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // Botão Conferir
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPink,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: const Text(
              'Conferir',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
