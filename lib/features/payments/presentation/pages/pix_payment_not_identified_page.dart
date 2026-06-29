import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/app/router/app_router.dart';

class PixPaymentNotIdentifiedPage extends StatelessWidget {
  const PixPaymentNotIdentifiedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pagamento PIX',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 18),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE4ED),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Color(0xFFC92D7A),
                  size: 54,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pagamento não identificado',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Não conseguimos confirmar o recebimento do seu PIX. O tempo limite pode ter expirado ou houve um problema na transação.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEEFF8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECFE4)),
              ),
              child: Text(
                'Verifique se o valor foi debitado da sua conta antes de tentar novamente.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC92D7A),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.pixPayment);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC92D7A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Tentar Novamente',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.payments);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFC92D7A)),
                  foregroundColor: const Color(0xFFC92D7A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Trocar Forma de Pagamento',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // abrir suporte no futuro
              },
              child: Text(
                'Precisa de ajuda? Fale com o suporte',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
