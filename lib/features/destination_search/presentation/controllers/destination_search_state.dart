import 'package:tmjapp/features/destination_search/domain/entities/place_suggestion.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';

class DestinationSearchState {
  const DestinationSearchState({
    required this.origin,
    required this.recentDestinations,
    required this.suggestions,
    required this.isLoading,
    required this.isResolvingOrigin,
    required this.isSearching,
    required this.errorMessage,
    required this.originErrorMessage,
    required this.query,
  });

  factory DestinationSearchState.initial() {
    return const DestinationSearchState(
      origin: null,
      recentDestinations: [],
      suggestions: [],
      isLoading: true,
      isResolvingOrigin: true,
      isSearching: false,
      errorMessage: null,
      originErrorMessage: null,
      query: '',
    );
  }

  final RouteLocation? origin;
  final List<RouteLocation> recentDestinations;
  final List<PlaceSuggestion> suggestions;
  final bool isLoading;
  final bool isResolvingOrigin;
  final bool isSearching;
  final String? errorMessage;
  final String? originErrorMessage;
  final String query;

  DestinationSearchState copyWith({
    RouteLocation? origin,
    List<RouteLocation>? recentDestinations,
    List<PlaceSuggestion>? suggestions,
    bool? isLoading,
    bool? isResolvingOrigin,
    bool? isSearching,
    String? errorMessage,
    String? originErrorMessage,
    String? query,
    bool clearErrorMessage = false,
    bool clearOriginErrorMessage = false,
    bool clearSuggestions = false,
  }) {
    return DestinationSearchState(
      origin: origin ?? this.origin,
      recentDestinations: recentDestinations ?? this.recentDestinations,
      suggestions: clearSuggestions ? const [] : (suggestions ?? this.suggestions),
      isLoading: isLoading ?? this.isLoading,
      isResolvingOrigin: isResolvingOrigin ?? this.isResolvingOrigin,
      isSearching: isSearching ?? this.isSearching,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      originErrorMessage: clearOriginErrorMessage
          ? null
          : (originErrorMessage ?? this.originErrorMessage),
      query: query ?? this.query,
    );
  }
}
