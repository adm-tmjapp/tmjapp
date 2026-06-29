import 'package:flutter/material.dart';
import 'package:tmjapp/utils/dimensions.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<_NotificationItem> _items = const [
    _NotificationItem(
      title: 'Verificação de Segurança',
      description: 'Um novo dispositivo acessou sua conta em São Paulo, SP. Foi você?',
      category: 'Segurança',
      timeLabel: 'Agora',
      color: Color(0xFFF06291),
      icon: Icons.check_circle_rounded,
      indicatorColor: Color(0xFFD21C5C),
    ),
    _NotificationItem(
      title: 'Cupom de 20% OFF!',
      description: 'Use o código MAGENTA20 na sua próxima viagem para o aeroporto.',
      category: 'Promoções',
      timeLabel: '2h atrás',
      color: Color(0xFF42B46A),
      icon: Icons.local_offer_rounded,
      indicatorColor: Color(0xFF13834A),
    ),
    _NotificationItem(
      title: 'Recibo da Viagem',
      description: 'Sua viagem de ontem às 18:30 foi finalizada. O valor de R\$ 24,90 foi debitado.',
      category: 'Recibos',
      timeLabel: 'Ontem',
      color: Color(0xFF9CA3AF),
      icon: Icons.receipt_long_rounded,
      indicatorColor: Color(0xFF6B7280),
    ),
    _NotificationItem.promo(
      title: 'Viagens Ilimitadas?',
      description: 'Conheça o novo plano Magenta Prime e economize em cada km.',
      ctaLabel: 'Saiba mais',
      gradient: [Color(0xFFE42C8B), Color(0xFFB21580)],
    ),
    _NotificationItem(
      title: 'Perfil Verificado',
      description: 'Parabéns! Sua conta agora possui o selo de confiança TMJApp.',
      category: 'Segurança',
      timeLabel: '3 dias atrás',
      color: Color(0xFF9CA3AF),
      icon: Icons.verified_user_rounded,
      indicatorColor: Color(0xFF6B7280),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recentes',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF101828),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Marcar todas como lidas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFC92D7A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  if (item.isPromo) {
                    return _PromoCard(item: item);
                  }
                  return _NotificationCard(item: item, theme: theme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF101828), size: 20),
          ),
          Text(
            'Notificações',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFC92D7A),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded,
                color: Color(0xFF667085), size: 22),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.theme});

  final _NotificationItem item;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF101828),
                        ),
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: item.indicatorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475467),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      item.category.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF9CA3AF),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF9CA3AF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.timeLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: item.gradient ?? const [Color(0xFFE42C8B), Color(0xFFB21580)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFC92D7A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: () {},
              child: Text(
                item.ctaLabel ?? 'Saiba mais',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.description,
    required this.category,
    required this.timeLabel,
    required this.color,
    required this.icon,
    required this.indicatorColor,
  })  : isPromo = false,
        gradient = null,
        ctaLabel = null;

  const _NotificationItem.promo({
    required this.title,
    required this.description,
    required this.gradient,
    this.ctaLabel,
  })  : category = '',
        timeLabel = '',
        color = Colors.white,
        icon = Icons.star,
        indicatorColor = Colors.white,
        isPromo = true;

  final String title;
  final String description;
  final String category;
  final String timeLabel;
  final Color color;
  final IconData icon;
  final Color indicatorColor;
  final bool isPromo;
  final List<Color>? gradient;
  final String? ctaLabel;
}
