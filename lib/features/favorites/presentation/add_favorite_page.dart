import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/features/destination_search/data/datasources/destination_search_local_datasource.dart';
import 'package:tmjapp/features/destination_search/data/datasources/destination_search_remote_datasource.dart';
import 'package:tmjapp/features/destination_search/data/repositories/destination_search_repository_impl.dart';
import 'package:tmjapp/features/destination_search/domain/entities/place_suggestion.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/resolve_destination_usecase.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/search_places_usecase.dart';
import 'package:tmjapp/features/favorites/presentation/controllers/add_favorite_address_controller.dart';
import 'package:tmjapp/features/favorites/presentation/controllers/add_favorite_address_state.dart';
import 'package:tmjapp/features/favorites/data/datasources/favorite_address_local_datasource.dart';

class AddFavoriteAddressPage extends StatefulWidget {
  final String? initialLabel;

  const AddFavoriteAddressPage({super.key, this.initialLabel});

  @override
  State<AddFavoriteAddressPage> createState() => _AddFavoriteAddressPageState();
}

class _AddFavoriteAddressPageState extends State<AddFavoriteAddressPage> {
  late final AddFavoriteAddressController _controller;
  late final TextEditingController _searchController;
  late final TextEditingController _aliasController;
  final FocusNode _searchFocus = FocusNode();
  GoogleMapController? _mapController;

  static const _defaultCenter = LatLng(-23.561684, -46.656139); // Av. Paulista

  @override
  void initState() {
    super.initState();
    final repository = DestinationSearchRepositoryImpl(
      localDataSource: DestinationSearchLocalDataSource(),
      remoteDataSource: DestinationSearchRemoteDataSource(),
    );

    _controller = AddFavoriteAddressController(
      searchPlacesUseCase: SearchPlacesUseCase(repository),
      resolveDestinationUseCase: ResolveDestinationUseCase(repository),
      favoriteAddressLocalDataSource: FavoriteAddressLocalDataSource(),
    );
    _searchController = TextEditingController();
    _aliasController = TextEditingController();

    // Auto-select label if initialLabel is provided
    if (widget.initialLabel != null && widget.initialLabel!.isNotEmpty) {
      _loadInitialFavorite(widget.initialLabel!);
    }
  }

  Future<void> _loadInitialFavorite(String label) async {
    await _controller.loadFavorite(label);
    if (!mounted) return;
    final location = _controller.state.selectedLocation;
    if (location == null) return;
    _searchController.text = location.title;
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(location.latitude, location.longitude),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _controller.dispose();
    _searchController.dispose();
    _aliasController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _setPreset(RouteLocation location) {
    _controller.setPresetLocation(location);
    _searchController.text = location.title;
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(location.latitude, location.longitude),
      ),
    );
  }

  Future<void> _handleSaveFavorite() async {
    await _controller.saveFavorite();
    if (!mounted) return;

    final state = _controller.state;
    if (state.successMessage != null && state.successMessage!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.successMessage!)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final AddFavoriteAddressState state = _controller.state;
            final selected = state.selectedLocation;

            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _MapHeader(
                        mapController: _mapController,
                        onMapCreated: (c) => _mapController = c,
                        marker: selected != null
                            ? Marker(
                                markerId: const MarkerId('selected'),
                                position: LatLng(
                                  selected.latitude,
                                  selected.longitude,
                                ),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRose,
                                ),
                              )
                            : null,
                        initialTarget: selected != null
                            ? LatLng(selected.latitude, selected.longitude)
                            : _defaultCenter,
                        searchField: _SearchField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          isLoading: state.isSearching,
                          onChanged: _controller.updateQuery,
                          onClear: () {
                            _searchController.clear();
                            _controller.updateQuery('');
                          },
                        ),
                        quickChips: [
                          _QuickChipData(
                            label: 'Shopping JK Iguatemi',
                            location: const RouteLocation(
                              title: 'Shopping JK Iguatemi',
                              subtitle:
                                  'Av. Pres. Juscelino, 2041 - Itaim Bibi',
                              latitude: -23.5881,
                              longitude: -46.6856,
                            ),
                          ),
                          _QuickChipData(
                            label: 'Rua Oscar Freire, 1100',
                            location: const RouteLocation(
                              title: 'Rua Oscar Freire, 1100',
                              subtitle: 'Cerqueira Cesar - SP',
                              latitude: -23.5646,
                              longitude: -46.6658,
                            ),
                          ),
                        ],
                        onQuickTap: _setPreset,
                        suggestions: state.suggestions,
                        onSuggestionTap: (s) async {
                          await _controller.selectSuggestion(s);
                          final loc = _controller.state.selectedLocation;
                          if (loc != null) {
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLng(
                                LatLng(loc.latitude, loc.longitude),
                              ),
                            );
                          }
                        },
                      ),
                      Transform.translate(
                        offset: const Offset(0, -32),
                        child: _BodyCard(
                          state: state,
                          aliasController: _aliasController,
                          onAliasChanged: _controller.updateCustomLabel,
                          onLabelTap: _controller.setLabel,
                          onSave: state.isSaving ? null : _handleSaveFavorite,
                          onCenter: selected != null
                              ? () => _mapController?.animateCamera(
                                    CameraUpdate.newLatLng(
                                      LatLng(
                                        selected.latitude,
                                        selected.longitude,
                                      ),
                                    ),
                                  )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: FavoritesBottomNavigation(
                    currentIndex: -1,
                    onTap: (index) {
                      switch (index) {
                        case 0:
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.dashboard);
                          break;
                        case 2:
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.tripHistory);
                          break;
                        case 3:
                          Navigator.of(context)
                              .pushReplacementNamed(AppRoutes.profile);
                          break;
                        default:
                          break;
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.mapController,
    required this.onMapCreated,
    required this.marker,
    required this.initialTarget,
    required this.searchField,
    required this.quickChips,
    required this.onQuickTap,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  final GoogleMapController? mapController;
  final Function(GoogleMapController) onMapCreated;
  final Marker? marker;
  final LatLng initialTarget;
  final Widget searchField;
  final List<_QuickChipData> quickChips;
  final ValueChanged<RouteLocation> onQuickTap;
  final List<PlaceSuggestion> suggestions;
  final ValueChanged<PlaceSuggestion> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Bar Estilizada
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Color(0xFF111827), size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Adicionar Endereço',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
        // Área do Mapa e Buscas
        Stack(
          children: [
            SizedBox(
              height: 320,
              width: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: 14.2,
                ),
                markers: marker != null ? {marker!} : {},
                zoomControlsEnabled: false,
                tiltGesturesEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                myLocationButtonEnabled: false,
                onMapCreated: onMapCreated,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                children: [
                  searchField,
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Row(
                      children: quickChips
                          .map(
                            (chip) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _QuickChip(
                                label: chip.label,
                                onTap: () => onQuickTap(chip.location),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  if (suggestions.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: suggestions
                            .map(
                              (suggestion) => _SuggestionTile(
                                suggestion: suggestion,
                                onTap: () => onSuggestionTap(suggestion),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BodyCard extends StatelessWidget {
  const _BodyCard({
    required this.state,
    required this.aliasController,
    required this.onAliasChanged,
    required this.onLabelTap,
    required this.onSave,
    required this.onCenter,
  });

  final AddFavoriteAddressState state;
  final TextEditingController aliasController;
  final ValueChanged<String> onAliasChanged;
  final ValueChanged<String> onLabelTap;
  final VoidCallback? onSave;
  final VoidCallback? onCenter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'LOCALIZAÇÃO SELECIONADA',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 12),
          _SelectedLocationCard(
            location: state.selectedLocation,
            onCenter: onCenter,
          ),
          const SizedBox(height: 28),
          Text(
            'DAR UM NOME AO LOCAL',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              for (final label in ['Casa', 'Trabalho', 'Academia'])
                _LabelPill(
                  label: label,
                  isSelected: state.selectedLabel == label,
                  onTap: () => onLabelTap(label),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: aliasController,
            onChanged: onAliasChanged,
            decoration: InputDecoration(
              hintText: 'Ex: Casa da Vovó',
              hintStyle: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFC7CBD1),
                fontWeight: FontWeight.w500,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF9E0D5A)),
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9E0D5A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: state.isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'SALVAR ENDEREÇO',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Color(0xFF9E0D5A),
                            size: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            _InlineMessage(message: state.errorMessage!, isError: true),
          ],
          if (state.successMessage != null) ...[
            const SizedBox(height: 16),
            _InlineMessage(message: state.successMessage!, isError: false),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.isLoading,
    required this.focusNode,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool isLoading;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF9E0D5A), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
              decoration: InputDecoration(
                hintText: 'Buscar novo endereço...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: Color(0xFF9CA3AF), size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onClear,
            ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF9E0D5A),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickChipData {
  const _QuickChipData({required this.label, required this.location});
  final String label;
  final RouteLocation location;
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.history_rounded,
                size: 16, color: Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.suggestion, required this.onTap});

  final PlaceSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.place_rounded, color: Color(0xFF9E0D5A)),
      title: Text(
        suggestion.title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        suggestion.subtitle,
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SelectedLocationCard extends StatelessWidget {
  const _SelectedLocationCard({required this.location, this.onCenter});

  final RouteLocation? location;
  final VoidCallback? onCenter;

  @override
  Widget build(BuildContext context) {
    if (location == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_off_outlined, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Nenhum endereço selecionado.',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFFCE4EC),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.place_rounded,
                color: Color(0xFF9E0D5A), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location!.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  location!.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onCenter != null)
            IconButton(
              onPressed: onCenter,
              icon: const Icon(Icons.my_location_rounded,
                  color: Color(0xFF9CA3AF)),
            ),
        ],
      ),
    );
  }
}

class _LabelPill extends StatelessWidget {
  const _LabelPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isSelected ? const Color(0xFF9E0D5A) : const Color(0xFF1F2937);
    final borderColor =
        isSelected ? const Color(0xFF9E0D5A) : const Color(0xFFE5E7EB);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, color: Color(0xFF9E0D5A), size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message, required this.isError});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFB91C1C) : const Color(0xFF047857);
    final bg = isError ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
              color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesBottomNavigation extends StatelessWidget {
  const FavoritesBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Início'),
      (Icons.explore_outlined, 'Explorar'),
      (Icons.receipt_long_outlined, 'Atividade'),
      (Icons.person_outline, 'Perfil'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;
              final color = isSelected
                  ? const Color(0xFF9E0D5A)
                  : const Color(0xFF9CA3AF);
              final bgColor =
                  isSelected ? const Color(0xFFFCE4EC) : Colors.transparent;

              return GestureDetector(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.$1, color: color, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        item.$2.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          letterSpacing: 0.2,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
