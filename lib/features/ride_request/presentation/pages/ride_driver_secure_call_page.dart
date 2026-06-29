import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RideDriverSecureCallPage extends StatelessWidget {
  const RideDriverSecureCallPage({
    super.key,
    required this.driverName,
    this.driverRating,
    required this.onStartCall,
  });

  final String driverName;
  final double? driverRating;
  final Future<void> Function() onStartCall;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFFC92D7A),
                      size: 26,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Expanded(
                    flex: 6,
                    child: Text(
                      'Ligar para Motorista',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 136,
              height: 136,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  size: 64,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              driverName.isNotEmpty ? driverName : 'João Santos',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Motorista Particular',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFF59E0B), size: 18),
                const SizedBox(width: 6),
                Text(
                  (driverRating != null
                      ? driverRating!.toStringAsFixed(1)
                      : '4.9'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Deseja ligar para o motorista agora?',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Para sua segurança, a chamada será realizada através do seu aplicativo de telefone padrão.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Seu número e o do motorista estão protegidos. A ligação é feita através de um canal seguro do TMJApp.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                  height: 1.6,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () async {
                        await onStartCall();
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC92D7A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        'Iniciar Chamada Segura',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475467),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Seus dados de contato nunca são compartilhados. O número exibido no identificador de chamadas será mascarado.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF94A3B8),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
