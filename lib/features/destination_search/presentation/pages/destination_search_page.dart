import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// 👇 AQUI: Adicionamos o import das rotas
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/features/destination_search/data/datasources/destination_search_local_datasource.dart';
import 'package:tmjapp/features/destination_search/data/datasources/destination_search_remote_datasource.dart';
import 'package:tmjapp/features/destination_search/data/repositories/destination_search_repository_impl.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/get_current_route_origin_usecase.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/get_recent_destinations_usecase.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/resolve_destination_usecase.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/save_recent_destination_usecase.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/search_places_usecase.dart';
import 'package:tmjapp/features/destination_search/presentation/controllers/destination_search_controller.dart';
import 'package:tmjapp/features/destination_search/presentation/widgets/destination_quick_chip.dart';
import 'package:tmjapp/features/destination_search/presentation/widgets/place_suggestion_tile.dart';
import 'package:tmjapp/features/destination_search/presentation/widgets/recent_destination_tile.dart';

class DestinationSearchPage extends StatefulWidget {
  const DestinationSearchPage({super.key});

  @override
  State<DestinationSearchPage> createState() => _DestinationSearchPageState();
}

class _DestinationSearchPageState extends State<DestinationSearchPage> {
  late final DestinationSearchController _controller;
  late final TextEditingController _queryController;
  late final FocusNode _queryFocusNode;
  String? _lastErrorMessage;
  String? _lastOriginErrorMessage;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
    _queryFocusNode = FocusNode();
    final repository = DestinationSearchRepositoryImpl(
      localDataSource: DestinationSearchLocalDataSource(),
      remoteDataSource: DestinationSearchRemoteDataSource(),
    );

    _controller = DestinationSearchController(
      getCurrentRouteOriginUseCase: GetCurrentRouteOriginUseCase(repository),
      getRecentDestinationsUseCase: GetRecentDestinationsUseCase(repository),
      searchPlacesUseCase: SearchPlacesUseCase(repository),
      resolveDestinationUseCase: ResolveDestinationUseCase(repository),
      saveRecentDestinationUseCase: SaveRecentDestinationUseCase(repository),
    )..addListener(_onStateChanged);

    _controller.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _queryFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onStateChanged)
      ..dispose();
    _queryController.dispose();
    _queryFocusNode.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final state = _controller.state;
    if (state.errorMessage != null &&
        state.errorMessage!.isNotEmpty &&
        state.errorMessage != _lastErrorMessage &&
        mounted) {
      _lastErrorMessage = state.errorMessage;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
    }

    if (state.errorMessage == null) {
      _lastErrorMessage = null;
    }

    if (state.originErrorMessage != null &&
        state.originErrorMessage!.isNotEmpty &&
        state.originErrorMessage != _lastOriginErrorMessage &&
        mounted) {
      _lastOriginErrorMessage = state.originErrorMessage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _showLocationAlert(state.originErrorMessage!);
      });
    }

    if (state.originErrorMessage == null) {
      _lastOriginErrorMessage = null;
    }
  }

  Future<void> _showLocationAlert(String message) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ative sua localização'),
          content: Text(
            '$message\n\nAtive o serviço de localização do aparelho e conceda permissao para o TMJApp acessar sua localização atual.',
          ),
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

  Future<void> _handleQuickChipTap(String label) async {
    final state = _controller.state;
    final match = state.recentDestinations.where((item) {
      final haystack = '${item.title} ${item.subtitle}'.toLowerCase();
      return haystack.contains(label.toLowerCase());
    }).toList();

    if (match.isEmpty) {
      _queryController.text = label;
      _controller.updateQuery(label);
      return;
    }

    final result = await _controller.selectRecentDestination(match.first);
    if (!mounted || result == null) {
      return;
    }

    Navigator.of(context).pop(result);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFE),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final state = _controller.state;

            return Stack(
              children: [
                // Conteúdo principal
                Column(
                  children: [
                    // Novo Cabeçalho "Para onde?"
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.arrow_back,
                                    color: Color(0xFF1D2939)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Para onde?',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1D2939),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded,
                                color: Color(0xFF1D2939)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: state.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 10, 16, 110),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _AddressFields(
                                    currentLocationLabel: state
                                            .isResolvingOrigin
                                        ? 'Localizando você...'
                                        : (state.origin?.title ??
                                            'Localização atual indisponível'),
                                    controller: _queryController,
                                    focusNode: _queryFocusNode,
                                    isSearching: state.isSearching,
                                    onChanged: _controller.updateQuery,
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(
                                      height: 1, color: Color(0xFFEAECF0)),
                                  const SizedBox(height: 16),
                                  if (state.originErrorMessage != null) ...[
                                    _OriginWarningCard(
                                      message: state.originErrorMessage!,
                                      isRetrying: state.isResolvingOrigin,
                                      onRetry: _controller.retryResolveOrigin,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        DestinationQuickChip(
                                          icon: Icons.home_outlined,
                                          label: 'Casa',
                                          onTap: () =>
                                              _handleQuickChipTap('Casa'),
                                        ),
                                        const SizedBox(width: 10),
                                        DestinationQuickChip(
                                          icon: Icons.work_outline_rounded,
                                          label: 'Trabalho',
                                          onTap: () =>
                                              _handleQuickChipTap('Trabalho'),
                                        ),
                                        const SizedBox(width: 10),
                                        DestinationQuickChip(
                                          icon: Icons.star_border_rounded,
                                          label: 'Salvos',
                                          onTap: () =>
                                              _handleQuickChipTap('Salvos'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  Text(
                                    state.suggestions.isNotEmpty
                                        ? 'RESULTADOS'
                                        : 'DESTINOS RECENTES',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF98A2B3),
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (state.suggestions.isNotEmpty)
                                    ...state.suggestions.map(
                                      (suggestion) => PlaceSuggestionTile(
                                        suggestion: suggestion,
                                        onTap: () async {
                                          final navigator =
                                              Navigator.of(context);
                                          final result = await _controller
                                              .selectSuggestion(suggestion);
                                          if (!mounted || result == null) {
                                            return;
                                          }
                                          navigator.pop(result);
                                        },
                                      ),
                                    ),
                                  if (state.suggestions.isEmpty &&
                                      state.recentDestinations.isNotEmpty)
                                    ...state.recentDestinations
                                        .asMap()
                                        .entries
                                        .map(
                                          (entry) => RecentDestinationTile(
                                            icon:
                                                _recentIconForIndex(entry.key),
                                            location: entry.value,
                                            onTap: () async {
                                              final navigator =
                                                  Navigator.of(context);
                                              final result = await _controller
                                                  .selectRecentDestination(
                                                      entry.value);
                                              if (!mounted || result == null) {
                                                return;
                                              }
                                              navigator.pop(result);
                                            },
                                          ),
                                        ),
                                  if (state.suggestions.isEmpty &&
                                      state.recentDestinations.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 28),
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
                // Banner promocional fixo inferior
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  // 👇 AQUI: Adicionado o GestureDetector para navegar
                  child: GestureDetector(
                    onTap: () {
                      // Remove o foco do teclado antes de navegar
                      FocusScope.of(context).unfocus();
                      Navigator.of(context)
                          .pushNamed(AppRoutes.promotionsAndCoupons);
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD22776),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33C72F79),
                            blurRadius: 16,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_offer_rounded,
                                color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Ganhe 20% de desconto\nIndique um amigo hoje',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: Colors.white),
                          ],
                        ),
                      ),
                    ),
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

class _OriginWarningCard extends StatelessWidget {
  const _OriginWarningCard({
    required this.message,
    required this.isRetrying,
    required this.onRetry,
  });

  final String message;
  final bool isRetrying;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDB022)),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location_rounded, color: Color(0xFFB54708)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF7A2E0E),
              ),
            ),
          ),
          TextButton(
            onPressed: isRetrying ? null : onRetry,
            child: Text(
              isRetrying ? '...' : 'Tentar',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: const Color(0xFFB54708),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressFields extends StatelessWidget {
  const _AddressFields({
    required this.currentLocationLabel,
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    required this.onChanged,
  });

  final String currentLocationLabel;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicadores visuais de linha de tempo
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Column(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF98A2B3),
                    width: 1.5,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 44,
                color: const Color(0xFFEAECF0),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFD22776),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Campos de Origem e Destino
        Expanded(
          child: Column(
            children: [
              // Campo: Localização Atual
              Container(
                height: 44,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB), // Leve tom cinza do figma
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEAECF0)),
                ),
                child: Text(
                  currentLocationLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF667085),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Campo: Para onde vamos?
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD22776)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: onChanged,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF1D2939),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Para onde vamos?',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF98A2B3),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (isSearching)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFD22776)),
                        ),
                      )
                    else
                      const Icon(
                        Icons.search_rounded,
                        color: Color(0xFFD22776),
                        size: 20,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
