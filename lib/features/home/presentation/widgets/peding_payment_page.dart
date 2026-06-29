import 'package:flutter/material.dart';
import 'package:tmjapp/features/home/presentation/pages/dashboard_page.dart';

// Constantes de cores baseadas no seu layout
const Color _primaryPink = Color(0xFFC92D7A);
const Color _textDark = Color(0xFF1D2939);
const Color _textLight = Color(0xFF667085);
const Color _bgLight = Color(0xFFFAFAFA);

class PendingPaymentPage extends StatefulWidget {
  final double debtAmount;

  const PendingPaymentPage({
    super.key,
    required this.debtAmount,
  });

  @override
  State<PendingPaymentPage> createState() => _PendingPaymentPageState();
}

class _PendingPaymentPageState extends State<PendingPaymentPage> {
  // 0 = PIX, 1 = Cartão
  int _selectedPaymentMethod = 0;

  @override
  Widget build(BuildContext context) {
    // Formata o valor
    final formattedAmount =
        widget.debtAmount.toStringAsFixed(2).replaceAll('.', ',');

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 200,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: _primaryPink),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Flexible(
              child: Text(
                'Pagamento',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _primaryPink,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Center(
              child: Text(
                'TMJ',
                style: TextStyle(
                  color: _primaryPink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ícone superior
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDE8F1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.more_horiz,
                          color: Color(0xFFA1195A), size: 32),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Títulos
                  const Text(
                    'Pagamento Pendente',
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Identificamos uma pendência em sua última viagem.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textLight,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Card de Valor Total
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'VALOR TOTAL',
                          style: TextStyle(
                            color: _textLight,
                            fontSize: 12,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 10.0, right: 4.0),
                              child: Text(
                                'R\$',
                                style: TextStyle(
                                  color: _primaryPink,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              formattedAmount,
                              style: const TextStyle(
                                color: _primaryPink,
                                fontSize: 64,
                                height: 1.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Divider(color: Colors.grey.shade200, height: 1),
                        const SizedBox(height: 16),

                        // Resumo da Viagem
                        Row(
                          children: [
                            const Icon(Icons.history, color: _textDark),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Viagem em 14 Nov',
                                    style: TextStyle(
                                      color: _textDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Centro para Vila Marina',
                                    style: TextStyle(
                                      color: _textLight,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: Colors.grey.shade400),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Alerta de bloqueio
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: _primaryPink),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Regularize seu débito para continuar solicitando novas corridas',
                            style: TextStyle(
                              color: _textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Título Métodos de Pagamento
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Métodos de Pagamento',
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Opção 1: PIX
                  _PaymentMethodCard(
                    icon: Icons.qr_code_2,
                    title: 'PIX',
                    subtitle: 'Aprovação instantânea',
                    iconBgColor: const Color(0xFFFDE8F1),
                    iconColor: _primaryPink,
                    isSelected: _selectedPaymentMethod == 0,
                    onTap: () => setState(() => _selectedPaymentMethod = 0),
                  ),
                  const SizedBox(height: 12),

                  // Opção 2: Cartão de Crédito
                  _PaymentMethodCard(
                    icon: Icons.credit_card,
                    title: '•••• 1234',
                    subtitle: 'Mastercard',
                    iconBgColor: Colors.grey.shade300,
                    iconColor: _textDark,
                    isSelected: _selectedPaymentMethod == 1,
                    onTap: () => setState(() => _selectedPaymentMethod = 1),
                  ),

                  const SizedBox(height: 40), // Espaço extra para o scroll
                ],
              ),
            ),
          ),

          // Botão Pagar Agora (Fixo no rodapé)
          Container(
            padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16),
            decoration: const BoxDecoration(
              color: _bgLight,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica de processar o pagamento aqui
                  // Ex: print('Pagar com método $_selectedPaymentMethod');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryPink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Pagar Agora',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// WIDGET PRIVADO PARA OS BOTÕES DE PAGAMENTO
class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBgColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBgColor,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF5F5F5),
          border: Border.all(
            color: isSelected ? _primaryPink : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _textLight,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Radio Button Customizado
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _primaryPink : Colors.grey.shade400,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
