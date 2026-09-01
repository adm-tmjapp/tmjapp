import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/features/profile/data/datasources/coupon_local_datasource.dart';
import 'package:tmjapp/features/profile/data/models/coupon.dart';

const _pink = Color(0xFFC92D7A);
const _lightPink = Color(0xFFFCE7F3);
const _background = Color(0xFFF8FAFC);
const _dark = Color(0xFF1D2939);
const _muted = Color(0xFF667085);

class PromotionsCouponsPage extends StatefulWidget {
  const PromotionsCouponsPage({super.key});
  @override
  State<PromotionsCouponsPage> createState() => _PromotionsCouponsPageState();
}

class _PromotionsCouponsPageState extends State<PromotionsCouponsPage> {
  final _controller = TextEditingController();
  final _source = CouponLocalDataSource();
  List<Coupon> _coupons = const [];
  String? _selected;
  bool _loading = true;
  bool _applying = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final coupons = await _source.getActiveCoupons();
    final selected = await _source.getSelectedCode();
    if (!mounted) return;
    setState(() {
      _coupons = coupons;
      _selected = coupons.any((c) => c.code == selected) ? selected : null;
      _loading = false;
    });
  }

  void _message(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor:
          error ? const Color(0xFFB42318) : const Color(0xFF16A34A),
    ));
  }

  Future<void> _apply() async {
    FocusScope.of(context).unfocus();
    if (_controller.text.trim().isEmpty) {
      _message('Digite um código de cupom.', error: true);
      return;
    }
    setState(() => _applying = true);
    try {
      final coupon = await _source.addCoupon(_controller.text);
      await _source.selectCoupon(coupon.code);
      _controller.clear();
      await _load();
      if (mounted) {
        _message('Cupom "${coupon.code}" aplicado com sucesso!');
      }
    } on CouponException catch (error) {
      if (mounted) _message(error.message, error: true);
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  Future<void> _details(Coupon coupon) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(coupon.title,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(coupon.description,
                    style: const TextStyle(color: _muted, height: 1.5)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.confirmation_number_outlined,
                      color: _pink),
                  title: Text(coupon.code),
                  subtitle: Text(_expiry(coupon)),
                  trailing: IconButton(
                    tooltip: 'Copiar código',
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: coupon.code));
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                      if (mounted) _message('Código ${coupon.code} copiado.');
                    },
                  ),
                ),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _selected == coupon.code
                          ? null
                          : () async {
                              await _source.selectCoupon(coupon.code);
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                              await _load();
                              if (mounted) {
                                _message(
                                    'Cupom ${coupon.code} selecionado para a próxima corrida.');
                              }
                            },
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(_selected == coupon.code
                          ? 'CUPOM SELECIONADO'
                          : 'USAR NA PRÓXIMA CORRIDA'),
                    )),
                SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('REMOVER CUPOM'),
                      onPressed: () async {
                        await _source.removeCoupon(coupon.code);
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                        await _load();
                        if (mounted) _message('Cupom ${coupon.code} removido.');
                      },
                    )),
              ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              icon:
                  const Icon(Icons.arrow_back_ios_new, color: _dark, size: 20),
              onPressed: () => Navigator.pop(context)),
          centerTitle: true,
          title: Text('Promoções e Cupons',
              style: GoogleFonts.plusJakartaSans(
                  color: _dark, fontWeight: FontWeight.w800, fontSize: 18)),
        ),
        body: SafeArea(
            child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Text('Adicionar um cupom',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15, fontWeight: FontWeight.w800, color: _dark)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!_applying) _apply();
                },
                decoration: InputDecoration(
                    hintText: 'Digite o código',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
              )),
              const SizedBox(width: 12),
              SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _applying ? null : _apply,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _pink, foregroundColor: Colors.white),
                    child: _applying
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Aplicar'),
                  )),
            ]),
            const SizedBox(height: 32),
            Text('CUPONS ATIVOS',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: _muted)),
            const SizedBox(height: 16),
            if (_loading)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator()))
            else if (_coupons.isEmpty)
              const _EmptyState()
            else
              ..._coupons.map((coupon) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CouponCard(
                        coupon: coupon,
                        selected: coupon.code == _selected,
                        onTap: () => _details(coupon)),
                  )),
          ]),
        )),
      );
}

String _expiry(Coupon c) =>
    'Válido até ${c.expiryDate.day.toString().padLeft(2, '0')}/${c.expiryDate.month.toString().padLeft(2, '0')}/${c.expiryDate.year}';

class _CouponCard extends StatelessWidget {
  const _CouponCard(
      {required this.coupon, required this.selected, required this.onTap});
  final Coupon coupon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: selected ? _pink : const Color(0xFFEAECF0),
                      width: selected ? 1.5 : 1)),
              child: Row(children: [
                Container(
                    width: 56,
                    height: 76,
                    decoration: BoxDecoration(
                        color: _lightPink,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.local_offer_rounded,
                        color: _pink, size: 28)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(children: [
                        Expanded(
                            child: Text(coupon.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: _dark))),
                        if (selected)
                          const Icon(Icons.check_circle, color: _pink, size: 20)
                      ]),
                      const SizedBox(height: 5),
                      Text(coupon.description,
                          style: const TextStyle(fontSize: 12, color: _muted)),
                      const SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(coupon.code,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1)),
                            Text(_expiry(coupon),
                                style: const TextStyle(
                                    fontSize: 11, color: _muted))
                          ]),
                    ])),
                const Icon(Icons.chevron_right, color: Color(0xFF98A2B3)),
              ]),
            )),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(children: [
          Icon(Icons.local_offer_outlined, size: 44, color: Color(0xFF98A2B3)),
          SizedBox(height: 12),
          Text('Nenhum cupom ativo',
              style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text('Adicione um código válido para vê-lo aqui.',
              style: TextStyle(color: _muted))
        ]),
      );
}
