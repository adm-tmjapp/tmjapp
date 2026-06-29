import 'package:tmjapp/features/ride_request/domain/entities/ride_driver_summary.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_method.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_option.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_product.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_realtime_session.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_stage.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_vehicle_summary.dart';

class RideRequestState {
  const RideRequestState({
    required this.stage,
    required this.rideId,
    required this.products,
    required this.selectedProductIndex,
    required this.selectedPaymentMethod,
    required this.paymentOptions,
    required this.isLoading,
    required this.isCancelling,
    required this.rideStatus,
    required this.statusUpdatedAt,
    required this.driver,
    required this.vehicle,
    required this.driverLatitude,
    required this.driverLongitude,
    required this.driverLocationUpdatedAt,
    required this.paymentMethodLabel,
    required this.realtimeSession,
    required this.errorMessage,
  });

  factory RideRequestState.initial() {
    return const RideRequestState(
      stage: RideStage.confirming,
      rideId: null,
      products: [],
      selectedProductIndex: -1,
      selectedPaymentMethod: RidePaymentMethod.card,
      paymentOptions: [],
      isLoading: true,
      isCancelling: false,
      rideStatus: null,
      statusUpdatedAt: null,
      driver: null,
      vehicle: null,
      driverLatitude: null,
      driverLongitude: null,
      driverLocationUpdatedAt: null,
      paymentMethodLabel: null,
      realtimeSession: null,
      errorMessage: null,
    );
  }

  final RideStage stage;
  final String? rideId;
  final List<RideProduct> products;
  final int selectedProductIndex;
  final RidePaymentMethod selectedPaymentMethod;
  final List<RidePaymentOption> paymentOptions;
  final bool isLoading;
  final bool isCancelling;
  final String? rideStatus;
  final DateTime? statusUpdatedAt;
  final RideDriverSummary? driver;
  final RideVehicleSummary? vehicle;
  final double? driverLatitude;
  final double? driverLongitude;
  final DateTime? driverLocationUpdatedAt;
  final String? paymentMethodLabel;
  final RideRealtimeSession? realtimeSession;
  final String? errorMessage;

  String get normalizedRideStatus =>
      (rideStatus ?? 'pending').trim().toLowerCase();

  String get statusTitle {
    switch (normalizedRideStatus) {
      case 'accepted':
        return 'Motorista a caminho';
      case 'ongoing':
        return 'Viagem em Curso';
      case 'completed':
        return 'Viagem finalizada';
      case 'canceled':
      case 'cancelled':
        return 'Corrida cancelada';
      default:
        return 'Procurando motoristas próximos...';
    }
  }

  String get statusDescription {
    switch (normalizedRideStatus) {
      case 'accepted':
        return 'Seu motorista aceitou a corrida e está vindo te buscar.';
      case 'ongoing':
        return 'Sua viagem já começou. Acompanhe o trajeto pelo mapa.';
      case 'completed':
        return 'Tudo certo. Sua corrida foi concluída com sucesso.';
      case 'canceled':
      case 'cancelled':
        return 'A solicitação foi cancelada. Você pode iniciar uma nova corrida.';
      default:
        return 'Isso pode levar alguns segundos';
    }
  }

  bool get canCancel {
    return !isCancelling &&
        (normalizedRideStatus == 'pending' ||
            normalizedRideStatus == 'accepted');
  }

  bool get hasDriverLocation =>
      driverLatitude != null && driverLongitude != null;

  String get paymentSummary {
    if ((paymentMethodLabel ?? '').trim().isNotEmpty) {
      return paymentMethodLabel!;
    }

    final selectedOption = paymentOptions
        .where((option) => option.method == selectedPaymentMethod)
        .cast<RidePaymentOption?>()
        .firstWhere(
          (option) => option != null,
          orElse: () => null,
        );

    if (selectedOption != null) {
      return selectedOption.label;
    }

    return selectedPaymentMethod.label;
  }

  String? get driverDisplayName {
    final value = driver?.name?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  String? get vehicleDisplayName {
    final model = vehicle?.model?.trim();
    final color = vehicle?.color?.trim();
    if ((model ?? '').isEmpty && (color ?? '').isEmpty) {
      return null;
    }

    if ((model ?? '').isNotEmpty && (color ?? '').isNotEmpty) {
      return '$model · $color';
    }

    return (model ?? color)!;
  }

  RideProduct? get selectedProduct {
    if (products.isEmpty ||
        selectedProductIndex < 0 ||
        selectedProductIndex >= products.length) {
      return null;
    }

    return products[selectedProductIndex];
  }

  RideRequestState copyWith({
    RideStage? stage,
    String? rideId,
    List<RideProduct>? products,
    int? selectedProductIndex,
    RidePaymentMethod? selectedPaymentMethod,
    List<RidePaymentOption>? paymentOptions,
    bool? isLoading,
    bool? isCancelling,
    String? rideStatus,
    DateTime? statusUpdatedAt,
    RideDriverSummary? driver,
    RideVehicleSummary? vehicle,
    double? driverLatitude,
    double? driverLongitude,
    DateTime? driverLocationUpdatedAt,
    String? paymentMethodLabel,
    RideRealtimeSession? realtimeSession,
    String? errorMessage,
    bool clearRideStatus = false,
    bool clearStatusUpdatedAt = false,
    bool clearDriver = false,
    bool clearVehicle = false,
    bool clearDriverLocation = false,
    bool clearPaymentMethodLabel = false,
    bool clearRealtimeSession = false,
    bool clearErrorMessage = false,
  }) {
    return RideRequestState(
      stage: stage ?? this.stage,
      rideId: rideId ?? this.rideId,
      products: products ?? this.products,
      selectedProductIndex: selectedProductIndex ?? this.selectedProductIndex,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      paymentOptions: paymentOptions ?? this.paymentOptions,
      isLoading: isLoading ?? this.isLoading,
      isCancelling: isCancelling ?? this.isCancelling,
      rideStatus: clearRideStatus ? null : (rideStatus ?? this.rideStatus),
      statusUpdatedAt: clearStatusUpdatedAt
          ? null
          : (statusUpdatedAt ?? this.statusUpdatedAt),
      driver: clearDriver ? null : (driver ?? this.driver),
      vehicle: clearVehicle ? null : (vehicle ?? this.vehicle),
      driverLatitude:
          clearDriverLocation ? null : (driverLatitude ?? this.driverLatitude),
      driverLongitude: clearDriverLocation
          ? null
          : (driverLongitude ?? this.driverLongitude),
      driverLocationUpdatedAt: clearDriverLocation
          ? null
          : (driverLocationUpdatedAt ?? this.driverLocationUpdatedAt),
      paymentMethodLabel: clearPaymentMethodLabel
          ? null
          : (paymentMethodLabel ?? this.paymentMethodLabel),
      realtimeSession: clearRealtimeSession
          ? null
          : (realtimeSession ?? this.realtimeSession),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
