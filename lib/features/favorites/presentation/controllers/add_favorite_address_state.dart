import 'package:tmjapp/features/destination_search/domain/entities/place_suggestion.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';

class AddFavoriteAddressState {
  const AddFavoriteAddressState({
    required this.query,
    required this.suggestions,
    required this.selectedLocation,
    required this.selectedLabel,
    required this.customLabel,
    required this.isSearching,
    required this.isSaving,
    required this.errorMessage,
    required this.successMessage,
  });

  factory AddFavoriteAddressState.initial() {
    return const AddFavoriteAddressState(
      query: '',
      suggestions: [],
      selectedLocation: null,
      selectedLabel: 'Casa',
      customLabel: '',
      isSearching: false,
      isSaving: false,
      errorMessage: null,
      successMessage: null,
    );
  }

  final String query;
  final List<PlaceSuggestion> suggestions;
  final RouteLocation? selectedLocation;
  final String selectedLabel;
  final String customLabel;
  final bool isSearching;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  AddFavoriteAddressState copyWith({
    String? query,
    List<PlaceSuggestion>? suggestions,
    RouteLocation? selectedLocation,
    String? selectedLabel,
    String? customLabel,
    bool? isSearching,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearSuggestions = false,
    bool clearSelectedLocation = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AddFavoriteAddressState(
      query: query ?? this.query,
      suggestions:
          clearSuggestions ? const [] : (suggestions ?? this.suggestions),
      selectedLocation: clearSelectedLocation
          ? null
          : (selectedLocation ?? this.selectedLocation),
      selectedLabel: selectedLabel ?? this.selectedLabel,
      customLabel: customLabel ?? this.customLabel,
      isSearching: isSearching ?? this.isSearching,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
