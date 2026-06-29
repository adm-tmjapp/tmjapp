import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Cores do seu padrão
const Color _primaryPink = Color(0xFFC92D7A);
const Color _bgPinkLight = Color(0xFFFCE7F3);
const Color _bgLight = Color(0xFFF8FAFC);
const Color _textDark = Color(0xFF1D2939);
const Color _textMedium = Color(0xFF344054);
const Color _textLight = Color(0xFF667085);

class PromotionsCouponsPage extends StatefulWidget {
  const PromotionsCouponsPage({super.key});

  @override
  State<PromotionsCouponsPage> createState() => _PromotionsCouponsPageState();
}

class _PromotionsCouponsPageState extends State<PromotionsCouponsPage> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    // Remove o foco do teclado
    FocusScope.of(context).unfocus();

    // Simulando a adição de um cupom
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cupom "$code" aplicado com sucesso!'),
        backgroundColor: const Color(0xFF16A34A), // Verde sucesso
      ),
    );
    _couponController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new, color: _textDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Promoções e Cupons',
          style: GoogleFonts.plusJakartaSans(
            color: _textDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CAMPO DE ADICIONAR CUPOM ---
              Text(
                'Adicionar um cupom',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Digite o código',
                        hintStyle: GoogleFonts.plusJakartaSans(
                            color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _primaryPink, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _applyCoupon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryPink,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Aplicar',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // --- LISTA DE CUPONS ATIVOS ---
              const _SectionTitle('CUPONS ATIVOS'),
              const SizedBox(height: 16),

              // Simulação de Cupons
              const _CouponCard(
                title: 'R\$ 10 OFF na próxima corrida',
                description: 'Válido para qualquer categoria de viagem.',
                code: 'TMJ10',
                expiryDate: 'Válido até 31/12/2026',
                isExpiringSoon: false,
              ),
              const SizedBox(height: 12),
              const _CouponCard(
                title: '15% de desconto',
                description:
                    'Desconto máximo de R\$ 15. Apenas pagamentos com cartão.',
                code: 'BEMVINDO15',
                expiryDate: 'Expira hoje!',
                isExpiringSoon: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGETS AUXILIARES
// ============================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: _textLight,
        ),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final String title;
  final String description;
  final String code;
  final String expiryDate;
  final bool isExpiringSoon;

  const _CouponCard({
    required this.title,
    required this.description,
    required this.code,
    required this.expiryDate,
    this.isExpiringSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                isExpiringSoon ? Colors.orange.shade200 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Aba esquerda do cupom (cor sólida)
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: const BoxDecoration(
              color: _bgPinkLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: const Center(
              child: Icon(Icons.local_offer_rounded,
                  color: _primaryPink, size: 32),
            ),
          ),
          // Linha tracejada simulando o picote do cupom
          Container(
            height: 100,
            width: 1,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                  style: BorderStyle
                      .none, // O Flutter não tem native dashed border simples em Containers, então usamos cor sólida clara
                ),
              ),
            ),
          ),
          // Conteúdo do Cupom
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          code,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _textMedium,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Text(
                        expiryDate,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isExpiringSoon
                              ? Colors.orange.shade700
                              : _textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
