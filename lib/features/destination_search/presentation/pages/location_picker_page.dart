import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/features/destination_search/data/datasources/destination_search_local_datasource.dart';
import 'package:tmjapp/features/destination_search/data/datasources/destination_search_remote_datasource.dart';
import 'package:tmjapp/features/destination_search/data/repositories/destination_search_repository_impl.dart';
import 'package:tmjapp/features/destination_search/domain/entities/place_suggestion.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/get_recent_destinations_usecase.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/resolve_destination_usecase.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/save_recent_destination_usecase.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/search_places_usecase.dart';
import 'package:tmjapp/features/destination_search/presentation/widgets/place_suggestion_tile.dart';
import 'package:tmjapp/features/destination_search/presentation/widgets/recent_destination_tile.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({
    super.key,
    required this.title,
    required this.hintText,
    this.initialQuery,
  });

  final String title;
  final String hintText;
  final String? initialQuery;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late final DestinationSearchRepositoryImpl _repository;
  late final SearchPlacesUseCase _searchPlacesUseCase;
  late final ResolveDestinationUseCase _resolveDestinationUseCase;
  late final SaveRecentDestinationUseCase _saveRecentDestinationUseCase;
  late final GetRecentDestinationsUseCase _getRecentDestinationsUseCase;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = const [];
  List<RouteLocation> _recentDestinations = const [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = DestinationSearchRepositoryImpl(
      localDataSource: DestinationSearchLocalDataSource(),
      remoteDataSource: DestinationSearchRemoteDataSource(),
    );
    _searchPlacesUseCase = SearchPlacesUseCase(_repository);
    _resolveDestinationUseCase = ResolveDestinationUseCase(_repository);
    _saveRecentDestinationUseCase = SaveRecentDestinationUseCase(_repository);
    _getRecentDestinationsUseCase = GetRecentDestinationsUseCase(_repository);
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _focusNode = FocusNode();
    _loadRecents();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final recents = await _getRecentDestinationsUseCase.execute();
      if (!mounted) {
        return;
      }
      setState(() {
        _recentDestinations = recents;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    if (!mounted) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSearching = value.trim().isNotEmpty;
      if (value.trim().isEmpty) {
        _suggestions = const [];
      }
    });

    if (value.trim().isEmpty) {
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final suggestions = await _searchPlacesUseCase.execute(value);
        if (!mounted) {
          return;
        }
        setState(() {
          _suggestions = suggestions;
          _isSearching = false;
        });
      } catch (error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isSearching = false;
          _errorMessage = error.toString().replaceFirst('Exception: ', '');
        });
      }
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    try {
      final result = await _resolveDestinationUseCase.execute(suggestion);
      await _saveRecentDestinationUseCase.execute(result);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(result);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1D2939),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      autofocus: true,
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: _onQueryChanged,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF98A2B3),
                        ),
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.search_rounded,
                                color: Color(0xFFC92D7A),
                              ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFC92D7A),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFC92D7A),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB42318),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      _suggestions.isNotEmpty
                          ? 'RESULTADOS'
                          : 'DESTINOS RECENTES',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF98A2B3),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_suggestions.isNotEmpty)
                      ..._suggestions.map(
                        (suggestion) => PlaceSuggestionTile(
                          suggestion: suggestion,
                          onTap: () => _selectSuggestion(suggestion),
                        ),
                      )
                    else if (_recentDestinations.isNotEmpty)
                      ..._recentDestinations.asMap().entries.map(
                            (entry) => RecentDestinationTile(
                              icon: _recentIconForIndex(entry.key),
                              location: entry.value,
                              onTap: () =>
                                  Navigator.of(context).pop(entry.value),
                            ),
                          )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            'Seus destinos recentes vao aparecer aqui.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF98A2B3),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _recentIconForIndex(int index) {
    const icons = [
      Icons.history_rounded,
      Icons.flight_takeoff_rounded,
      Icons.restaurant_rounded,
      Icons.business_rounded,
      Icons.place_rounded,
      Icons.location_city_rounded,
    ];
    return icons[index % icons.length];
  }
}
