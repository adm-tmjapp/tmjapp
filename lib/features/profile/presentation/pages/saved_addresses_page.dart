import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedAddressesPage extends StatelessWidget {
  const SavedAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
              child: ListView(
                children: [
                  _AddressCard(
                    title: 'Casa',
                    subtitle: 'Rua das Flores, 123 - Jardins',
                    icon: Icons.home_rounded,
                  ),
                  const SizedBox(height: 12),
                  _AddressCard(
                    title: 'Trabalho',
                    subtitle: 'Av. Paulista, 1500 - 10º Andar',
                    icon: Icons.work_rounded,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Outros favoritos',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AddressCard(
                    title: 'Academia',
                    subtitle: 'Rua Treze de Maio, 440',
                    icon: Icons.fitness_center_rounded,
                  ),
                  const SizedBox(height: 12),
                  _AddressCard(
                    title: 'Casa da Mãe',
                    subtitle: 'Rua Oscar Freire, 890',
                    icon: Icons.favorite_border_rounded,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFF1F5F9),
                        child: Icon(Icons.location_on_outlined,
                            color: Color(0xFF0F172A)),
                      ),
                      title: Text(
                        'Localização Atual',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: Text(
                        'Av. Brigadeiro Faria Lima, 3477',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      trailing: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.my_location_rounded,
                            color: Color(0xFF0C4A6E), size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Ação de adicionar novo endereço (pendente).')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC92D7A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'Adicionar Novo Endereço',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

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
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF9CA3AF)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Editar $title')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Excluir $title')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
