import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RideCancellationPolicyPage extends StatefulWidget {
  const RideCancellationPolicyPage({
    super.key,
    required this.cancellationFee,
    required this.onConfirmCancellation,
    required this.onDismiss,
  });

  final double cancellationFee;
  final Function(String? reason) onConfirmCancellation;
  final VoidCallback onDismiss;

  @override
  State<RideCancellationPolicyPage> createState() =>
      _RideCancellationPolicyPageState();
}

class _RideCancellationPolicyPageState
    extends State<RideCancellationPolicyPage> {
  String? selectedReason;

  final List<Map<String, String>> cancellationReasons = [
    {'id': 'delay', 'label': 'Demora muito'},
    {'id': 'changed_mind', 'label': 'Mudei de ideia'},
    {'id': 'wrong_address', 'label': 'Endereço errado'},
    {'id': 'safety', 'label': 'Segurança'},
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Substituído Scaffold por Material
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              // 2. CRUCIAL: Impede que a coluna tente crescer infinitamente
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- CABEÇALHO CUSTOMIZADO (Substitui o AppBar) ---
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Color(0xFF1E293B), size: 24),
                      onPressed: widget.onDismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Cancelamento',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- ALERTA: Motorista a caminho ---
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC92D7A),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'O motorista já está a caminho',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Cancelar agora impactará o deslocamento do profissional.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- RESUMO DE TAXA ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RESUMO DE TAXA',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF98A2B3),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'R\$ ${widget.cancellationFee.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFC92D7A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1ECFE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.info_rounded,
                                color: Color(0xFFC92D7A), size: 14),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'A Taxa de Cancelamento de R\$ ${widget.cancellationFee.toStringAsFixed(2).replaceAll('.', ',')} será aplicada para cobrir os custos de combustível e tempo do motorista que já iniciou o trajeto até você.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF667085),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- MOTIVOS PARA CANCELAR ---
                Text(
                  'Por que deseja cancelar?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                ...cancellationReasons.map((reason) {
                  final isSelected = selectedReason == reason['id'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedReason = reason['id'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF1ECFE)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFC92D7A)
                                : const Color(0xFFF1F5F9),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFC92D7A)
                                      : const Color(0xFFD0D5DD),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFC92D7A),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              reason['label']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFFC92D7A)
                                    : const Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 24),

                // --- BOTÃO MANTER VIAGEM ---
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: widget.onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC92D7A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'MANTER VIAGEM',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- LINK CONFIRMAR CANCELAMENTO ---
                Center(
                  child: GestureDetector(
                    onTap: selectedReason != null
                        ? () => widget.onConfirmCancellation(selectedReason)
                        : null,
                    child: Padding(
                      // Adicionando um pequeno padding para facilitar o clique
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Confirmar Cancelamento',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selectedReason != null
                              ? const Color(0xFFC92D7A)
                              : const Color(0xFFD0D5DD),
                          decoration: TextDecoration.underline,
                          decorationColor: selectedReason != null
                              ? const Color(0xFFC92D7A)
                              : const Color(0xFFD0D5DD),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
