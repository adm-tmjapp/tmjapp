import 'package:tmjapp/features/trip_history/domain/entities/trip_history_item.dart';

class TripHistoryState {
  const TripHistoryState({
    this.isLoading = true,
    this.selectedTab = 0,
    this.allTrips = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final int selectedTab;
  final List<TripHistoryItem> allTrips;
  final String? errorMessage;

  List<TripHistoryItem> get visibleTrips {
    if (selectedTab == 0) {
      return allTrips
          .where((trip) => trip.status == 'Concluida' || trip.status == 'Cancelada')
          .toList(growable: false);
    }

    return allTrips
        .where((trip) => trip.status != 'Concluida' && trip.status != 'Cancelada')
        .toList(growable: false);
  }

  TripHistoryState copyWith({
    bool? isLoading,
    int? selectedTab,
    List<TripHistoryItem>? allTrips,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TripHistoryState(
      isLoading: isLoading ?? this.isLoading,
      selectedTab: selectedTab ?? this.selectedTab,
      allTrips: allTrips ?? this.allTrips,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
