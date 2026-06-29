import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_request_args.dart';
import 'package:tmjapp/features/ride_request/presentation/pages/ride_request_page.dart';

class PixPaymentProcessingPage extends StatefulWidget {
  final double amount;
  final RideRequestArgs? rideArgs;
  final bool paymentIdentified;

  const PixPaymentProcessingPage({
    super.key,
    required this.amount,
    this.rideArgs,
    this.paymentIdentified = true,
  });

  @override
  State<PixPaymentProcessingPage> createState() =>
      _PixPaymentProcessingPageState();
}

class _PixPaymentProcessingPageState extends State<PixPaymentProcessingPage> {
  int _secondsLeft = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        timer.cancel();
        _onComplete();
        return;
      }
      setState(() {
        _secondsLeft -= 1;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onComplete() {
    if (!mounted) return;

    // Se o pagamento falhar, vai para a tela de erro normalmente
    if (!widget.paymentIdentified) {
      Navigator.of(context)
          .pushReplacementNamed(AppRoutes.pixPaymentNotIdentified);
      return;
    }

    // SE DEU CERTO: Nós APAGAMOS todo aquele pushReplacement.
    // Agora apenas fechamos a tela da ampulheta devolvendo 'true'.
    // A tela anterior (PixPaymentPage) vai receber esse 'true' e fechar também!
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          // Adicionamos o SingleChildScrollView aqui para garantir que o card
          // possa rolar em telas menores e evitar o erro de overflow.
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.hourglass_top,
                        color: Color(0xFFC92D7A),
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Processando Pagamento',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Por favor, não feche esta tela.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: CircularProgressIndicator(
                        strokeWidth: 8,
                        color: const Color(0xFFC92D7A),
                        value: (5 - _secondsLeft) / 5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Verificando seu pagamento... ($_secondsLeft s)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Estamos confirmando o recebimento do seu PIX com a instituição financeira. Isso geralmente leva apenas alguns segundos.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailRow(
                              label: 'VALOR DO PASSE',
                              value:
                                  "R\$ ${widget.amount.toStringAsFixed(2).replaceAll('.', ',')}"),
                          const SizedBox(height: 8),
                          const _DetailRow(
                              label: 'DESTINO', value: 'Centro Comercial'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFECEFF3),
                          foregroundColor: const Color(0xFF94A3B8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          'Aguarde um momento',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'TMJApp • Pagamento Seguro via PIX',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF94A3B8),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
