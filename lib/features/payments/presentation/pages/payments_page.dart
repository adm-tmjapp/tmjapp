import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/features/home/presentation/widgets/home_bottom_navigation.dart';
import 'package:tmjapp/features/payments/data/datasources/payments_remote_datasource.dart';
import 'package:tmjapp/features/payments/domain/entities/payment_method_item.dart';
import 'package:tmjapp/features/payments/presentation/controllers/payments_controller.dart';
import 'package:tmjapp/features/payments/presentation/pages/add_balance_page.dart';
import 'package:tmjapp/features/payments/presentation/pages/payment_method_demo_page.dart';
// 👇 AQUI: Import da nova tela de adicionar cartão adicionado 👇
import 'package:tmjapp/features/payments/presentation/pages/add_card_page.dart';

// Cores baseadas no layout da imagem
const Color _primaryPink = Color(0xFFB1226B);
const Color _textDark = Color(0xFF1D2939);
const Color _textLight = Color(0xFF667085);
const Color _bgLight = Color(0xFFF9FAFB);

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  late final PaymentsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaymentsController(
      remoteDataSource: PaymentsRemoteDataSource(),
    )..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final state = _controller.state;

            return Column(
              children: [
                const _Header(
                  title: 'Meus Pagamentos',
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    children: [
                      _TmjPayCard(
                        balance: state.balance,
                        completedRides: state.completedRides,
                        onAddBalanceTap: () async {
                          // 1. Abre a nova tela e aguarda o usuário escolher o valor
                          final selectedAmount =
                              await Navigator.of(context).push<double>(
                            MaterialPageRoute(
                              builder: (_) => const AddBalancePage(),
                            ),
                          );

                          // 2. Se o usuário escolheu um valor e confirmou:
                          if (selectedAmount != null && selectedAmount > 0) {
                            if (!context.mounted) return;
                            await _controller.addBalance(selectedAmount);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Saldo de R\$ ${selectedAmount.toStringAsFixed(2).replaceAll('.', ',')} adicionado.'),
                                backgroundColor: _primaryPink,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle('CARTÕES SALVOS'),
                      const SizedBox(height: 12),

                      // Lógica de estado mantida, mas envelopada no novo layout branco
                      if (state.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 28),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: _primaryPink)),
                        )
                      else if (state.errorMessage != null)
                        _InlineMessage(message: state.errorMessage!)
                      else if (state.methods.isEmpty)
                        const _InlineMessage(
                          message: 'Nenhum cartão salvo encontrado.',
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children:
                                state.methods.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return Column(
                                children: [
                                  if (item.isLocal)
                                    _SavedCreditCard(
                                      item: item,
                                      onEdit: () => _openCardForm(item),
                                    )
                                  else
                                    _PaymentMethodTile(item: item),
                                  if (index < state.methods.length - 1)
                                    Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Colors.grey.shade100,
                                        indent: 64),
                                ],
                              );
                            }).toList(),
                          ),
                        ),

                      const SizedBox(height: 16),
                      // 👇 AQUI: Botão estático de Adicionar Cartão atualizado 👇
                      GestureDetector(
                        onTap: () async {
                          // Navega para a tela de adicionar cartão e aguarda o resultado
                          await _openCardForm(null);
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.add_circle_outline_rounded,
                                color: _primaryPink, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Adicionar Novo Cartão',
                              style: GoogleFonts.plusJakartaSans(
                                color: _primaryPink,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      const _SectionTitle('OUTROS MÉTODOS'),
                      const SizedBox(height: 12),

                      // Lista estática de Outros Métodos conforme imagem
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _OtherMethodTile(
                              icon: Icons.pix_rounded,
                              iconColor: const Color(0xFF16A34A),
                              iconBgColor: const Color(0xFFDCFCE7),
                              title: 'PIX',
                              subtitle: 'Pague instantaneamente',
                              onTap: () => _openMethodDemo(
                                PaymentMethodDemo.pix,
                              ),
                            ),
                            Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey.shade100,
                                indent: 64),
                            _OtherMethodTile(
                              icon: Icons.payments_rounded,
                              iconColor: const Color(0xFF15803D),
                              iconBgColor: const Color(0xFFDCFCE7),
                              title: 'Dinheiro',
                              subtitle: 'Pague diretamente ao motorista',
                              onTap: () => _openMethodDemo(
                                PaymentMethodDemo.cash,
                              ),
                            ),
                            Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey.shade100,
                                indent: 64),
                            _OtherMethodTile(
                              icon: Icons.account_balance_wallet_rounded,
                              iconColor: const Color(0xFF334155),
                              iconBgColor: const Color(0xFFF1F5F9),
                              title: 'Google Pay',
                              subtitle: 'Configurado via dispositivo',
                              onTap: () => _openMethodDemo(
                                PaymentMethodDemo.googlePay,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Card Promocional conforme imagem
                      const _PromoCard(),
                    ],
                  ),
                ),
                HomeBottomNavigation(
                  currentIndex: 2,
                  onTap: (index) => _handleBottomNavigation(context, index),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleBottomNavigation(BuildContext context, int index) {
    debugPrint('Payments bottom nav tap -> $index');
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(AppRoutes.tripHistory);
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed(AppRoutes.payments);
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
        break;
      default:
        break;
    }
  }

  Future<void> _openCardForm(PaymentMethodItem? existingCard) async {
    final result = await Navigator.of(context).push<CardFormResult>(
      MaterialPageRoute(
        builder: (_) => AddCardPage(card: existingCard),
      ),
    );
    if (result == null || !mounted) return;

    final replacesNumber = result.cardNumberDigits.isNotEmpty;
    final last4 = replacesNumber
        ? result.cardNumberDigits.substring(result.cardNumberDigits.length - 4)
        : existingCard!.last4!;
    final brand = replacesNumber
        ? _detectCardBrand(result.cardNumberDigits)
        : existingCard!.brand;
    await _controller.saveCard(
      PaymentMethodItem(
        id: existingCard?.id ??
            'local-${DateTime.now().microsecondsSinceEpoch}',
        brand: brand,
        label: '${_brandLabel(brand)} •••• $last4',
        subtitle: result.holderName,
        last4: last4,
        holderName: result.holderName,
        expiry: result.expiry,
        isLocal: true,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(existingCard == null
            ? 'Cartão salvo com sucesso!'
            : 'Cartão atualizado com sucesso!'),
        backgroundColor: const Color(0xFF16A34A),
      ),
    );
  }

  void _openMethodDemo(PaymentMethodDemo method) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentMethodDemoPage(method: method),
      ),
    );
  }

  String _detectCardBrand(String digits) {
    if (digits.startsWith('636368') || digits.startsWith('438935')) {
      return 'elo';
    }
    if (digits.startsWith('4')) return 'visa';
    final prefix = int.tryParse(digits.substring(0, 2)) ?? 0;
    if (prefix >= 51 && prefix <= 55) return 'mastercard';
    return 'card';
  }

  String _brandLabel(String brand) {
    return switch (brand) {
      'visa' => 'Visa',
      'mastercard' => 'Mastercard',
      'elo' => 'Elo',
      _ => 'Cartão',
    };
  }
}

class _TmjPayCard extends StatelessWidget {
  const _TmjPayCard({
    required this.balance,
    required this.completedRides,
    required this.onAddBalanceTap,
  });

  final double balance;
  final int completedRides;
  final VoidCallback onAddBalanceTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryPink,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryPink.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo TMJ Pay',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'R\$ ',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                balance.toStringAsFixed(2).replaceAll('.', ','),
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Botão Interativo
          GestureDetector(
            onTap: onAddBalanceTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Adicionar Saldo',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: _textLight,
      ),
    );
  }
}

class _SavedCreditCard extends StatelessWidget {
  const _SavedCreditCard({required this.item, required this.onEdit});

  final PaymentMethodItem item;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final brand = switch (item.brand.toLowerCase()) {
      'visa' => 'VISA',
      'mastercard' => 'MASTERCARD',
      'elo' => 'ELO',
      _ => 'CRÉDITO',
    };
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 174),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB1226B), Color(0xFF761546)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33B1226B),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.credit_card_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const Spacer(),
                Text(
                  brand,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '••••  ••••  ••••  ${item.last4}',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _CardDetail(
                    label: 'TITULAR',
                    value: item.holderName ?? item.subtitle,
                  ),
                ),
                _CardDetail(label: 'VALIDADE', value: item.expiry ?? '--/--'),
                const SizedBox(width: 12),
                Semantics(
                  button: true,
                  label: 'Editar cartão final ${item.last4}',
                  child: InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardDetail extends StatelessWidget {
  const _CardDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({required this.item});

  final PaymentMethodItem item;

  @override
  Widget build(BuildContext context) {
    // Definindo ícones estáticos simulando o design para "Mastercard/Visa"
    final bool isVisa = item.label.toLowerCase().contains('visa');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(
              isVisa ? Icons.payment_rounded : Icons.credit_card_rounded,
              color: isVisa ? const Color(0xFF1A1F71) : const Color(0xFFEB001B),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OtherMethodTile extends StatelessWidget {
  const _OtherMethodTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F8), // Fundo rosa claro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFBCFE8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.card_giftcard_rounded,
              color: _primaryPink, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ganhe R\$ 10 de desconto',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ao cadastrar seu primeiro cartão Mastercard.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: _textLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _textLight,
        ),
      ),
    );
  }
}

// ============================================================================
// ENTIDADE DE DOMÍNIO
// ============================================================================
class AddBalanceIntent {
  final double amount;
  final String paymentMethodId;
  final DateTime requestedAt;

  AddBalanceIntent({
    required this.amount,
    required this.paymentMethodId,
    DateTime? requestedAt,
  }) : requestedAt = requestedAt ?? DateTime.now();
}
