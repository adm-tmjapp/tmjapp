import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum PaymentMethodDemo { pix, cash, googlePay }

class PaymentMethodDemoPage extends StatelessWidget {
  const PaymentMethodDemoPage({
    super.key,
    required this.method,
  });

  final PaymentMethodDemo method;

  @override
  Widget build(BuildContext context) {
    final content = _DemoContent.forMethod(method);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFFB1226B),
          ),
        ),
        title: Text(
          content.title,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF1D2939),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                children: [
                  _HeroCard(content: content),
                  const SizedBox(height: 28),
                  Text(
                    'COMO FUNCIONA',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF667085),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (var index = 0; index < content.steps.length; index++)
                    _StepTile(
                      number: index + 1,
                      text: content.steps[index],
                      isLast: index == content.steps.length - 1,
                    ),
                  const SizedBox(height: 20),
                  _InformationCard(content: content),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  key: const Key('payment-method-demo-close'),
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFB1226B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'ENTENDI',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.content});

  final _DemoContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [content.color, content.darkColor],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: content.color.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
              ),
            ),
            child: Icon(content.icon, color: Colors.white, size: 38),
          ),
          const SizedBox(height: 18),
          Text(
            content.headline,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.text,
    required this.isLast,
  });

  final int number;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFFCE7F3),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFB1226B),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: const Color(0xFFFBCFE8),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22, top: 6),
              child: Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF344054),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.content});

  final _DemoContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFB1226B),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content.note,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF475467),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoContent {
  const _DemoContent({
    required this.title,
    required this.headline,
    required this.description,
    required this.steps,
    required this.note,
    required this.icon,
    required this.color,
    required this.darkColor,
  });

  final String title;
  final String headline;
  final String description;
  final List<String> steps;
  final String note;
  final IconData icon;
  final Color color;
  final Color darkColor;

  factory _DemoContent.forMethod(PaymentMethodDemo method) {
    return switch (method) {
      PaymentMethodDemo.pix => const _DemoContent(
          title: 'Pagamento via PIX',
          headline: 'Rápido, seguro e instantâneo',
          description:
              'Na corrida, você recebe um código PIX para concluir o pagamento no aplicativo do seu banco.',
          steps: [
            'Escolha PIX como forma de pagamento ao confirmar a corrida.',
            'Copie o código PIX exibido pelo TMJApp.',
            'Cole o código no aplicativo do seu banco e confirme o pagamento.',
            'Volte ao TMJApp enquanto validamos o pagamento.',
          ],
          note:
              'A corrida só é solicitada depois que o pagamento é identificado. Nunca faça PIX para uma chave enviada por mensagem.',
          icon: Icons.pix_rounded,
          color: Color(0xFF16A34A),
          darkColor: Color(0xFF08783E),
        ),
      PaymentMethodDemo.cash => const _DemoContent(
          title: 'Pagamento em dinheiro',
          headline: 'Pague ao final da corrida',
          description:
              'Você combina o pagamento diretamente com o motorista quando chegar ao destino.',
          steps: [
            'Escolha Dinheiro como forma de pagamento ao confirmar a corrida.',
            'Confira o valor estimado antes de solicitar o motorista.',
            'Ao chegar ao destino, entregue o valor indicado no aplicativo.',
            'Confirme com o motorista se precisar receber troco.',
          ],
          note:
              'Tenha o valor aproximado disponível. O preço final pode mudar em caso de alteração de rota ou outras condições informadas no app.',
          icon: Icons.payments_rounded,
          color: Color(0xFF15803D),
          darkColor: Color(0xFF075B2B),
        ),
      PaymentMethodDemo.googlePay => const _DemoContent(
          title: 'Google Pay',
          headline: 'Pague com sua carteira digital',
          description:
              'Use um cartão compatível salvo na Carteira do Google para pagar pelo dispositivo.',
          steps: [
            'Cadastre um cartão compatível no aplicativo Carteira do Google.',
            'Escolha Google Pay ao selecionar a forma de pagamento da corrida.',
            'Confirme o cartão e autorize o pagamento no dispositivo.',
            'Acompanhe a confirmação diretamente no TMJApp.',
          ],
          note:
              'Esta tela é demonstrativa. A disponibilidade do Google Pay depende do dispositivo, da instituição financeira e da integração ativa no app.',
          icon: Icons.account_balance_wallet_rounded,
          color: Color(0xFF334155),
          darkColor: Color(0xFF111827),
        ),
    };
  }
}
