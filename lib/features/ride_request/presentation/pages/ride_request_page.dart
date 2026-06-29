import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/destination_search/presentation/pages/location_picker_page.dart';
import 'package:tmjapp/features/home/data/datasources/home_local_datasource.dart';
import 'package:tmjapp/features/home/data/datasources/home_remote_datasource.dart';
import 'package:tmjapp/features/home/data/repositories/home_repository_impl.dart';
import 'package:tmjapp/features/home/domain/entities/home_location.dart';
import 'package:tmjapp/features/home/domain/usecases/build_trip_preview_usecase.dart';
import 'package:tmjapp/features/ride_request/data/datasources/ride_request_remote_datasource.dart';
import 'package:tmjapp/features/ride_request/data/repositories/ride_request_repository_impl.dart';

import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_method.dart';
import 'package:tmjapp/features/payments/presentation/pages/cadas_card_page.dart';

import 'package:tmjapp/features/ride_request/domain/entities/ride_request_args.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_stage.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/cancel_ride_usecase.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/checkout_ride_usecase.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/create_ride_quote_usecase.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/get_ride_detail_usecase.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/get_ride_eta_usecase.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/get_ride_payment_options_usecase.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/get_ride_status_usecase.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/issue_ride_realtime_token_usecase.dart';
import 'package:tmjapp/features/ride_request/presentation/controllers/ride_request_controller.dart';
import 'package:tmjapp/features/ride_request/presentation/controllers/ride_request_state.dart';
import 'package:tmjapp/features/ride_request/presentation/widgets/ride_confirm_sheet.dart';
import 'package:tmjapp/features/ride_request/presentation/widgets/ride_driver_assigned_sheet.dart';
import 'package:tmjapp/features/ride_request/presentation/widgets/ride_searching_sheet.dart';
import 'package:tmjapp/features/ride_request/presentation/widgets/ride_in_progress_sheet.dart';
import 'package:tmjapp/features/ride_request/presentation/widgets/ride_finished_sheet.dart';
import 'package:tmjapp/features/ride_request/presentation/widgets/ride_cancellation_policy_sheet.dart';
import 'package:tmjapp/features/ride_request/presentation/pages/ride_driver_secure_call_page.dart';
import 'package:tmjapp/features/ride_request/presentation/widgets/ride_cancelled_successfully_sheet.dart';
import 'package:tmjapp/features/chat/button_chat.dart';

class RideRequestPage extends StatefulWidget {
  const RideRequestPage({
    super.key,
    required this.args,
    this.onClearActiveRide,
  });

  final RideRequestArgs args;
  final VoidCallback? onClearActiveRide;

  @override
  State<RideRequestPage> createState() => _RideRequestPageState();
}

class _RideRequestPageState extends State<RideRequestPage> {
  late final RideRequestController _controller;
  GoogleMapController? _mapController;
  String? _lastErrorMessage;
  List<HomeLocation> _approachRoutePoints = const [];
  String? _lastApproachRouteKey;

  @override
  void initState() {
    super.initState();
    final repository = RideRequestRepositoryImpl(
      remoteDataSource: RideRequestRemoteDataSource(),
    );

    _controller = RideRequestController(
      args: widget.args,
      createRideQuoteUseCase: CreateRideQuoteUseCase(repository),
      getRidePaymentOptionsUseCase: GetRidePaymentOptionsUseCase(repository),
      checkoutRideUseCase: CheckoutRideUseCase(repository),
      getRideStatusUseCase: GetRideStatusUseCase(repository),
      getRideDetailUseCase: GetRideDetailUseCase(repository),
      getRideEtaUseCase: GetRideEtaUseCase(repository),
      issueRideRealtimeTokenUseCase: IssueRideRealtimeTokenUseCase(repository),
      cancelRideUseCase: CancelRideUseCase(repository),
    )..addListener(_onStateChanged);

    _controller.initialize();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _controller
      ..removeListener(_onStateChanged)
      ..dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final errorMessage = _controller.state.errorMessage;
    if (errorMessage != null &&
        errorMessage.isNotEmpty &&
        errorMessage != _lastErrorMessage &&
        mounted) {
      _lastErrorMessage = errorMessage;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage)));
    }

    if (errorMessage == null) {
      _lastErrorMessage = null;
    }

    _syncApproachRoute();
  }

  Set<Marker> _buildMarkers() {
    final state = _controller.state;
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('origin'),
        position: LatLng(
          widget.args.origin.latitude,
          widget.args.origin.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(
          widget.args.destination.latitude,
          widget.args.destination.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };

    if (state.hasDriverLocation) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(
            state.driverLatitude!,
            state.driverLongitude!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    final points = _controller.state.stage == RideStage.driverAssigned &&
            _approachRoutePoints.isNotEmpty
        ? _approachRoutePoints
        : widget.args.routePoints;

    if (points.isEmpty) {
      return const {};
    }

    return {
      Polyline(
        polylineId: const PolylineId('ride-request-route'),
        color: const Color(0xFFC92D7A),
        width: 5,
        points: points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(),
      ),
    };
  }

  Set<Circle> _buildCircles() {
    final state = _controller.state;

    final isSearchingDriver = state.stage != RideStage.confirming &&
        state.stage != RideStage.driverAssigned &&
        state.stage != RideStage.rideInProgress;

    if (isSearchingDriver) {
      return {
        Circle(
          circleId: const CircleId('radar_circle'),
          center: LatLng(
            widget.args.origin.latitude,
            widget.args.origin.longitude,
          ),
          radius: 800,
          fillColor: const Color(0xFFC92D7A).withOpacity(0.12),
          strokeColor: const Color(0xFFC92D7A).withOpacity(0.4),
          strokeWidth: 2,
        ),
      };
    }
    return const {};
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _centerMap() {
    final points = _controller.state.stage == RideStage.driverAssigned &&
            _approachRoutePoints.isNotEmpty
        ? _approachRoutePoints
        : widget.args.routePoints;
    if (_mapController == null || points.isEmpty) {
      return;
    }

    final latitudes = points.map((point) => point.latitude).toList()..sort();
    final longitudes = points.map((point) => point.longitude).toList()..sort();

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(latitudes.first, longitudes.first),
          northeast: LatLng(latitudes.last, longitudes.last),
        ),
        60,
      ),
    );
  }

  void _openSOS() {
    Navigator.of(context).pushNamed(AppRoutes.sos);
  }

  Future<void> _handleRequestRide(RidePaymentMethod paymentMethod) async {
    try {
      if (paymentMethod == RidePaymentMethod.pix) {
        final success = await _openPixPayment();
        if (success == true) {
          await _controller.requestRide();
        }
      } else if (paymentMethod == RidePaymentMethod.card) {
        final String? selectedCardId = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const RegisteredCardsPage()),
        );

        if (selectedCardId != null) {
          await _controller.requestRide(cardId: selectedCardId);
        }
      } else if (paymentMethod == RidePaymentMethod.cash) {
        await _controller.requestRide();
      }
    } catch (e) {}
  }

  Future<bool?> _openPixPayment() async {
    final selectedProduct = _controller.state.selectedProduct;
    final amount = selectedProduct?.estimatedPrice ?? 0.0;
    if (amount <= 0.0) return false;
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.pixPayment,
      arguments: {'amount': amount, 'rideArgs': widget.args},
    );
    return result == true;
  }

  Future<void> _syncApproachRoute() async {
    final state = _controller.state;
    if (state.stage != RideStage.driverAssigned || !state.hasDriverLocation) {
      if (_approachRoutePoints.isNotEmpty && mounted) {
        setState(() {
          _approachRoutePoints = const [];
          _lastApproachRouteKey = null;
        });
      }
      return;
    }

    final routeKey =
        '${state.driverLatitude},${state.driverLongitude}:${widget.args.origin.latitude},${widget.args.origin.longitude}';
    if (_lastApproachRouteKey == routeKey) return;

    _lastApproachRouteKey = routeKey;
    try {
      final route = await _buildRoutePoints(
        origin: RouteLocation(
          title: state.driverDisplayName ?? 'Motorista',
          subtitle: '',
          latitude: state.driverLatitude!,
          longitude: state.driverLongitude!,
        ),
        destination: widget.args.origin,
      );
      if (!mounted) return;
      setState(() => _approachRoutePoints = route);
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerMap());
    } catch (_) {
      if (!mounted) return;
      setState(() => _approachRoutePoints = const []);
    }
  }

  String _titleForStage(RideStage stage, {bool driverArrived = false}) {
    if (driverArrived) {
      return 'Motorista Chegou';
    }
    switch (stage) {
      case RideStage.confirming:
        return 'Confirmar Corrida';
      case RideStage.driverAssigned:
        return 'Motorista a caminho';
      case RideStage.rideInProgress:
        return 'Viagem em Curso';
      case RideStage.completed:
        return 'Viagem Finalizada';
      default:
        return 'Solicitação de Viagem';
    }
  }

  Future<void> _dialDriver() async {
    final phoneNumber = _controller.state.driver?.phoneNumber;
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;
    // Prefix to hide caller ID in Brazil. Adjust or configure per region as needed.
    const hideCallerIdPrefix = '#31#';
    final sanitized = phoneNumber.trim();
    final dialNumber = '$hideCallerIdPrefix$sanitized';
    final uri = Uri(scheme: 'tel', path: dialNumber);
    await launchUrl(uri);
  }

  Future<void> _openDriverChat() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ChatScreen(),
      ),
    );
  }

  Future<void> _callDriver() async {
    final driverName = _controller.state.driverDisplayName ?? 'Motorista';
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RideDriverSecureCallPage(
          driverName: driverName,
          driverRating: _controller.state.driver?.rating,
          onStartCall: _dialDriver,
        ),
      ),
    );
  }

  Future<void> _openNavigationToDriver() async {
    final state = _controller.state;
    if (!state.hasDriverLocation) return;
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${state.driverLatitude},${state.driverLongitude}');
    await launchUrl(uri);
  }

  bool _isDriverArrived(RideRequestState state) {
    if (!state.hasDriverLocation) return false;

    final distanceKm = _distanceBetween(
      state.driverLatitude!,
      state.driverLongitude!,
      widget.args.origin.latitude,
      widget.args.origin.longitude,
    );
    return distanceKm <= 0.08;
  }

  bool _shouldShowDriverArrived(RideRequestState state) {
    if (!state.hasDriverLocation) return false;
    if (state.stage == RideStage.confirming ||
        state.stage == RideStage.searchingDriver) {
      return false;
    }
    return _isDriverArrived(state);
  }

  double _distanceBetween(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  void _showPendingActionMessage(String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
          SnackBar(content: Text('$label será disponibilizado em breve.')));
  }

  Future<void> _handleCancelRide() async {
    final state = _controller.state;

    // Regra de negócio visual: Se o motorista já foi atribuído ou a viagem
    // está em andamento, exibimos a política de cancelamento.
    final shouldShowCancellationPolicy =
        state.stage == RideStage.driverAssigned ||
            state.stage == RideStage.rideInProgress;

    if (shouldShowCancellationPolicy) {
      // Valor padrão de taxa de cancelamento
      const cancellationFee = 5.0;

      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => RideCancellationPolicyPage(
            cancellationFee: cancellationFee,
            onDismiss: () => Navigator.of(context).pop(false),
            onConfirmCancellation: (reason) {
              Navigator.of(context).pop(true);
            },
          ),
        ),
      );

      // Se o usuário não confirmou o cancelamento, saímos
      if (result != true) return;
    }

    // Se não havia taxa (ex: estava apenas buscando) ou o usuário confirmou,
    // disparamos a ação real de cancelamento no Controller.
    _controller.cancelSearching();
  }

  Future<void> _editOrigin() async {
    final selectedOrigin = await Navigator.of(context).push<RouteLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          title: 'Alterar local de partida',
          hintText: 'Digite o endereço de partida',
          initialQuery: widget.args.origin.title,
        ),
      ),
    );
    if (selectedOrigin == null || !mounted) return;
    await _replaceRideRequest(
        origin: selectedOrigin, destination: widget.args.destination);
  }

  Future<void> _editDestination() async {
    final selectedDestination = await Navigator.of(context).push<RouteLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          title: 'Alterar destino',
          hintText: 'Digite para onde você vai',
          initialQuery: widget.args.destination.title,
        ),
      ),
    );
    if (selectedDestination == null || !mounted) return;
    await _replaceRideRequest(
        origin: widget.args.origin, destination: selectedDestination);
  }

  Future<void> _replaceRideRequest(
      {required RouteLocation origin,
      required RouteLocation destination}) async {
    try {
      final routePoints =
          await _buildRoutePoints(origin: origin, destination: destination);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RideRequestPage(
            args: RideRequestArgs(
              userId: widget.args.userId,
              origin: origin,
              destination: destination,
              routePoints: routePoints,
            ),
            onClearActiveRide: widget.onClearActiveRide,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<List<HomeLocation>> _buildRoutePoints(
      {required RouteLocation origin, required RouteLocation destination}) {
    final repository = HomeRepositoryImpl(
        localDataSource: HomeLocalDataSource(),
        remoteDataSource: HomeRemoteDataSource());
    return BuildTripPreviewUseCase(repository).execute(
      origin:
          HomeLocation(latitude: origin.latitude, longitude: origin.longitude),
      destination: HomeLocation(
          latitude: destination.latitude, longitude: destination.longitude),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final state = _controller.state;

          // --- PASSO 1 DA ALTERAÇÃO AQUI! ---
          // Intercepta a tela ANTES de desenhar o Stack inteiro com o Mapa.
          // Isso garante que a tela de sucesso ocupe 100% livremente.
          if (state.stage == RideStage.cancelled) {
            return RideCancelledSuccessfullyPage(
              onBackToDashboard: () {
                widget.onClearActiveRide?.call();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            );
          }

          final selectedProduct = state.selectedProduct;
          final isDriverArrived = _shouldShowDriverArrived(state);
          final isCompleted = state.stage == RideStage.completed;

          return Stack(
            children: [
              // --- MAPA OU FUNDO DEGRADÊ ---
              if (!isCompleted)
                Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.args.origin.latitude,
                          widget.args.origin.longitude),
                      zoom: 12.8,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _centerMap());
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    markers: _buildMarkers(),
                    polylines: _buildPolylines(),
                    circles: _buildCircles(),
                  ),
                )
              else
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
                      ),
                    ),
                  ),
                ),

              // --- HEADER CONDICIONAL ---
              if (!isCompleted)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 12,
                      left: 16,
                      right: 16,
                    ),
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Color(0xFFF8FAFC)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 60,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_rounded,
                                    color: Color(0xFFC92D7A), size: 24),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _titleForStage(state.stage,
                                    driverArrived: isDriverArrived),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            Container(
                              width: 60,
                              alignment: Alignment.centerRight,
                              child: (state.stage == RideStage.driverAssigned ||
                                      state.stage == RideStage.rideInProgress)
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: InkWell(
                                        onTap: _openSOS,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: const Color(0xFFDC2626),
                                                width: 1.5),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            'SOS',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFFDC2626),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // --- BOTÕES DO MAPA ---
              if (!isCompleted)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 90,
                  right: 16,
                  child: Column(
                    children: [
                      _MapFloatingButton(icon: Icons.add, onTap: _zoomIn),
                      const SizedBox(height: 12),
                      _MapFloatingButton(icon: Icons.remove, onTap: _zoomOut),
                      const SizedBox(height: 12),
                      _MapFloatingButton(
                          icon: Icons.my_location_rounded,
                          onTap: _centerMap,
                          isAccent: true),
                    ],
                  ),
                ),

              // --- ÁREA DAS SHEETS ---
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: isCompleted ? 0 : MediaQuery.of(context).padding.top + 90,
                child: Align(
                  alignment: isCompleted
                      ? Alignment.topCenter
                      : Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SafeArea(
                      top: isCompleted,
                      bottom: true,
                      child: switch (state.stage) {
                        RideStage.confirming => RideConfirmSheet(
                            origin: widget.args.origin,
                            destination: widget.args.destination,
                            isLoading: state.isLoading,
                            products: state.products,
                            selectedProductIndex: state.selectedProductIndex,
                            selectedPaymentMethod: state.selectedPaymentMethod,
                            paymentOptions: state.paymentOptions,
                            onSelectProduct: _controller.selectProduct,
                            onSelectPaymentMethod:
                                _controller.selectPaymentMethod,
                            onEditOrigin: _editOrigin,
                            onEditDestination: _editDestination,
                            onRequestRide: () =>
                                _handleRequestRide(state.selectedPaymentMethod),
                          ),
                        RideStage.driverAssigned => RideDriverAssignedSheet(
                            etaLabel:
                                selectedProduct?.etaLabel ?? 'Chega em 3 min',
                            driverName: state.driverDisplayName,
                            driverRating: state.driver?.rating,
                            vehiclePlate: state.vehicle?.licensePlate,
                            vehicleSummary: state.vehicleDisplayName,
                            onCall: _callDriver,
                            onChat: _openDriverChat,
                            onShare: _openNavigationToDriver,
                            onCancel: _handleCancelRide,
                            canCancel: state.canCancel,
                            driverArrived: isDriverArrived,
                            meetingPointAddress: widget.args.origin.title,
                            onConfirmComing: () =>
                                _showPendingActionMessage('Estou indo'),
                          ),
                        RideStage.rideInProgress => isDriverArrived
                            ? RideDriverAssignedSheet(
                                etaLabel: selectedProduct?.etaLabel ??
                                    'Chega em 3 min',
                                driverName: state.driverDisplayName,
                                driverRating: state.driver?.rating,
                                vehiclePlate: state.vehicle?.licensePlate,
                                vehicleSummary: state.vehicleDisplayName,
                                onCall: _callDriver,
                                onChat: _openDriverChat,
                                onShare: _openNavigationToDriver,
                                onCancel: _handleCancelRide,
                                canCancel: state.canCancel,
                                driverArrived: true,
                                meetingPointAddress: widget.args.origin.title,
                                onConfirmComing: () =>
                                    _showPendingActionMessage('Estou indo'),
                              )
                            : RideInProgressSheet(
                                etaLabel: selectedProduct?.etaLabel ?? '8 min',
                                driverName: state.driverDisplayName,
                                driverRating: state.driver?.rating,
                                vehiclePlate: state.vehicle?.licensePlate,
                                vehicleSummary: state.vehicleDisplayName,
                                onCall: _callDriver,
                                onChat: _openDriverChat,
                                onShare: () =>
                                    _showPendingActionMessage('Compartilhar'),
                              ),
                        RideStage.completed => RideFinishedSheet(
                            originTitle: widget.args.origin.title,
                            destinationTitle: widget.args.destination.title,
                            driverName: state.driverDisplayName,
                            finalPrice: selectedProduct?.estimatedPrice ?? 0.0,
                            paymentMethod: state.paymentSummary,
                            onFinish: () {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            onClearActiveRide: widget.onClearActiveRide,
                          ),
                        _ => RideSearchingSheet(
                            origin: widget.args.origin,
                            destination: widget.args.destination,
                            product: selectedProduct!,
                            paymentSummary: state.paymentSummary,
                            statusTitle: state.statusTitle,
                            statusDescription: state.statusDescription,
                            driverName: state.driverDisplayName,
                            driverRating: state.driver?.rating,
                            vehicleSummary: state.vehicleDisplayName,
                            plate: state.vehicle?.licensePlate,
                            hasRealtimeTracking: state.realtimeSession != null,
                            hasDriverLocation: state.hasDriverLocation,
                            isCancelling: state.isCancelling,
                            canCancel: state.canCancel,
                            onSOS: _openSOS,
                            onCancel: _handleCancelRide,
                          ),
                      },
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

class _MapFloatingButton extends StatelessWidget {
  const _MapFloatingButton(
      {required this.icon, required this.onTap, this.isAccent = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool isAccent;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon,
                color: isAccent
                    ? const Color(0xFFC92D7A)
                    : const Color(0xFF475467),
                size: 24),
          ),
        ),
      ),
    );
  }
}
