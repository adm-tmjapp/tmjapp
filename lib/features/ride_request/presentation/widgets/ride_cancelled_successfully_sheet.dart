import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RideCancelledSuccessfullyPage extends StatelessWidget {
  const RideCancelledSuccessfullyPage({
    super.key,
    required this.onBackToDashboard,
  });

  final VoidCallback onBackToDashboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: GestureDetector(
          onTap: onBackToDashboard,
          child: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1E293B), size: 24),
        ),
        title: Text(
          'Cancelamento',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // --- ÍCONE DE SUCESSO ---
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1ECFE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC92D7A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 48),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- TÍTULO ---
              Center(
                child: Text(
                  'Corrida Cancelada',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- DESCRIÇÃO ---
              Text(
                'Sua solicitação foi encerrada com sucesso. Conforme nossa política, não foi aplicada taxa de cancelamento para esta viagem.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF667085),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),

              // --- MAPA (placeholder) ---
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEF7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFFE8EEF7),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.map_rounded,
                            size: 48,
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: Color(0xFFC92D7A), size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Sua localização',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF344054),
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
              const SizedBox(height: 40),

              // --- BOTÃO VOLTAR PARA O INÍCIO ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onBackToDashboard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC92D7A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    'VOLTAR PARA O INÍCIO',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- FOOTER ---
              Center(
                child: Text(
                  'TMJApp · Experiência Premium',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF98A2B3),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
