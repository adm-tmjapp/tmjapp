import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Ajuda e Suporte',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.headset_mic_rounded,
                    color: Color(0xFFC92D7A),
                    size: 72,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Suporte 24h',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nossa equipe está sempre pronta para ajudar você em qualquer momento da sua jornada.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15803D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ONLINE 24/7',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Entre em contato',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 14),
            _ContactOption(
              icon: Icons.chat_bubble_outline,
              title: 'Chat ao vivo',
              subtitle: 'Fale com o suporte agora',
            ),
            const SizedBox(height: 12),
            _ContactOption(
              icon: Icons.phone_in_talk_rounded,
              title: 'Ligação',
              subtitle: '0800 123 4567',
            ),
            const SizedBox(height: 12),
            _ContactOption(
              icon: Icons.email_outlined,
              title: 'E-mail',
              subtitle: 'suporte@tmjapp.com.br',
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  const _ContactOption({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC92D7A), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
