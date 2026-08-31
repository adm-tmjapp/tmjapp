import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/destination_search/presentation/pages/location_picker_page.dart';
import 'package:tmjapp/features/favorites/data/datasources/favorite_address_local_datasource.dart';
import 'package:tmjapp/features/favorites/presentation/add_favorite_page.dart';

class SavedAddressesPage extends StatefulWidget {
  const SavedAddressesPage({super.key});

  @override
  State<SavedAddressesPage> createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  final _dataSource = FavoriteAddressLocalDataSource();
  Map<String, RouteLocation> _favorites = const {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _dataSource.getAllFavorites();
    if (!mounted) return;
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> _editFavorite(String label, RouteLocation current) async {
    final location = await Navigator.of(context).push<RouteLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          title: 'Editar $label',
          hintText: 'Digite o novo endereço',
          initialQuery: current.title,
        ),
      ),
    );
    if (location == null || !mounted) return;
    try {
      await _dataSource.saveFavorite(label: label, location: location);
      await _loadFavorites();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label atualizado com sucesso.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _deleteFavorite(String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir endereço?'),
        content: Text('O endereço “$label” será removido dos seus favoritos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _dataSource.deleteFavorite(label);
      await _loadFavorites();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label excluído com sucesso.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _addFavorite() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddFavoriteAddressPage()),
    );
    if (saved == true) await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _favorites.entries.toList()
      ..sort((a, b) => _orderFor(a.key).compareTo(_orderFor(b.key)));
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Endereços Salvos',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Gerencie seus destinos favoritos',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : entries.isEmpty
                        ? const _EmptyAddresses()
                        : ListView.separated(
                            itemCount: entries.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              return _AddressCard(
                                title: entry.key,
                                subtitle: _addressText(entry.value),
                                icon: _iconFor(entry.key),
                                onEdit: () =>
                                    _editFavorite(entry.key, entry.value),
                                onDelete: () => _deleteFavorite(entry.key),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _addFavorite,
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text(
                    'Adicionar Novo Endereço',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC92D7A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _addressText(RouteLocation location) {
    if (location.subtitle.trim().isEmpty ||
        location.title.contains(location.subtitle)) {
      return location.title;
    }
    return '${location.title} — ${location.subtitle}';
  }

  int _orderFor(String label) => switch (label.toLowerCase()) {
        'casa' => 0,
        'trabalho' => 1,
        'academia' => 2,
        _ => 3,
      };

  IconData _iconFor(String label) => switch (label.toLowerCase()) {
        'casa' => Icons.home_rounded,
        'trabalho' => Icons.work_rounded,
        'academia' => Icons.fitness_center_rounded,
        _ => Icons.favorite_border_rounded,
      };
}

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off_outlined,
              size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(
            'Nenhum endereço salvo.',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF8FAFC),
          child: Icon(icon, color: const Color(0xFF6B7280)),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar $title',
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF9CA3AF)),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'Excluir $title',
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
