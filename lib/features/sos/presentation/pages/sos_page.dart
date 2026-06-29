import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/app/router/app_router.dart';

class SosPage extends StatelessWidget {
  const SosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'SOS Emergência',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A)),
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECF2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF9D6E6)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEBE0F2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_rounded,
                            color: Color(0xFFC92D7A), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Você está em segurança?',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFC92D7A),
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Use os recursos abaixo apenas em caso de emergência real durante sua viagem.',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'DETALHES DA VIAGEM',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF6B7280),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'ID: TMJ-882391',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF94A3B8),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Localização Atual',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF475569),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Av. Paulista, 1578 - Bela Vista, São Paulo',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF334155),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: const Color(0xFFE2E8F0),
                            child: const Center(
                              child: Icon(Icons.map_rounded,
                                  size: 44, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: implementar compartilhar localização em tempo real
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFF1F7),
                            foregroundColor: const Color(0xFFC92D7A),
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFECB3D1)),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            'Compartilhar Localização em Tempo Real',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text('CANAIS DE EMERGÊNCIA',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 10),
                _EmergencyChannelTile(
                  icon: Icons.shield_moon_rounded,
                  iconColor: const Color(0xFF0D9488),
                  title: 'Polícia Militar',
                  subtitle: 'Ligar para 190',
                  onTap: () {
                    // TODO: chamar telefone 190
                  },
                ),
                _EmergencyChannelTile(
                  icon: Icons.medical_services_outlined,
                  iconColor: const Color(0xFFDC2626),
                  title: 'SAMU',
                  subtitle: 'Ligar para 192',
                  onTap: () {
                    // TODO: chamar telefone 192
                  },
                ),
                _EmergencyChannelTile(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFFF97316),
                  title: 'Bombeiros',
                  subtitle: 'Ligar para 193',
                  onTap: () {
                    // TODO: chamar telefone 193
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Central de Ajuda TMJ',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nossa equipe de segurança está disponível 24h para suporte imediato.',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFE2E8F0),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: implementar suporte TMJ
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0F172A),
                            elevation: 0,
                            side: BorderSide(
                                color: Colors.white.withOpacity(0.32)),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Falar com Suporte TMJ',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const SizedBox(height: 0),
    );
  }
}

class _EmergencyChannelTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _EmergencyChannelTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        trailing: const Icon(Icons.call, color: Color(0xFF94A3B8), size: 20),
        onTap: onTap,
      ),
    );
  }
}
