import 'package:tmjapp/features/payments/domain/entities/payment_method_item.dart';

class PaymentsState {
  const PaymentsState({
    this.isLoading = true,
    this.totalSpent = 0,
    this.completedRides = 0,
    this.methods = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final double totalSpent;
  final int completedRides;
  final List<PaymentMethodItem> methods;
  final String? errorMessage;

  PaymentsState copyWith({
    bool? isLoading,
    double? totalSpent,
    int? completedRides,
    List<PaymentMethodItem>? methods,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentsState(
      isLoading: isLoading ?? this.isLoading,
      totalSpent: totalSpent ?? this.totalSpent,
      completedRides: completedRides ?? this.completedRides,
      methods: methods ?? this.methods,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
