import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/features/payments/domain/pix_payment_data.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_request_args.dart';
import 'package:flutter/services.dart';
import 'package:tmjapp/api/base_api.dart';

class PixPaymentPage extends StatefulWidget {
  final double amount;
  final bool paymentValidated;
  final bool paymentFailed; // Nova variável para controlar a tela de erro
  final RideRequestArgs? rideArgs;
  final String? rideId;

  const PixPaymentPage({
    super.key,
    required this.amount,
    this.paymentValidated = false,
    this.paymentFailed = false, // Por padrão, a tela de erro fica oculta
    this.rideArgs,
    this.rideId,
  });

  @override
  State<PixPaymentPage> createState() => _PixPaymentPageState();
}

class _PixPaymentPageState extends State<PixPaymentPage>
    with WidgetsBindingObserver {
  static const _initialSeconds = 5 * 60;
  late int _secondsLeft;
  Timer? _timer;
  final _api = BaseApi();
  String? _pixCode;
  String? _encodedImage;
  String? _paymentId;
  String? _paymentStatus;
  DateTime? _paymentExpiresAt;
  String? _errorMessage;
  bool _isCreating = true;
  bool _isRefreshing = false;
  bool _didComplete = false;

  bool get _isPaid => isPixPaidStatus(_paymentStatus);

  bool get _paymentClosed {
    return isPixClosedStatus(_paymentStatus) || _secondsLeft <= 0;
  }

  String get _timerLabel {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes : $seconds';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _secondsLeft = _initialSeconds;
    unawaited(_createPayment());
    // O timer só roda se não for a tela de erro
    if (!widget.paymentFailed) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (timer.tick % 3 == 0) unawaited(_refreshPaymentStatus());
        if (_secondsLeft <= 0) {
          timer.cancel();
          unawaited(_expirePayment());
          return;
        }
        setState(() {
          _secondsLeft -= 1;
        });
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshPaymentStatus());
    }
  }

  Future<void> _copyPixCode() async {
    if ((_pixCode ?? '').isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _pixCode!));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Código PIX copiado para a área de transferência.')),
    );
  }

  Future<void> _createPayment() async {
    final id = widget.rideId ?? widget.rideArgs?.existingRideId;
    if (id == null || id.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _isCreating = false;
          _errorMessage = 'Corrida não identificada.';
        });
      }
      return;
    }
    try {
      final response = await _api.post(
        Uri.parse('v2/passenger/rides/$id/payments/pix'),
        body: {'amount': widget.amount},
      );
      final decoded = jsonDecode(response.body);
      final payload = decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          payload['message'] ??
              payload['error'] ??
              'Não foi possível gerar o PIX.',
        );
      }
      final payment = PixPaymentData.fromJson(payload);
      if ((payment.copyPasteCode ?? '').isEmpty) {
        throw Exception('O banco não retornou o código PIX. Tente novamente.');
      }
      if (mounted) {
        setState(() {
          _paymentId = payment.paymentId;
          _paymentStatus = payment.status;
          _paymentExpiresAt = payment.expiresAt;
          if (_paymentExpiresAt != null) {
            _secondsLeft = _paymentExpiresAt!
                .difference(DateTime.now())
                .inSeconds
                .clamp(0, 60 * 60);
          }
          _pixCode = payment.copyPasteCode;
          _encodedImage = normalizedPixBase64(payment.encodedImage);
          _isCreating = false;
          _errorMessage = null;
        });
      }
      if (payment.isPaid) _completePayment();
      unawaited(_refreshPaymentStatus());
    } catch (error) {
      if (mounted) {
        setState(() {
          _isCreating = false;
          _errorMessage = error.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _refreshPaymentStatus({bool showFeedback = false}) async {
    final rideId = widget.rideId ?? widget.rideArgs?.existingRideId;
    if (rideId == null || _pixCode == null || _isRefreshing) return;
    if (mounted) setState(() => _isRefreshing = true);
    try {
      final response = await _api
          .get(Uri.parse('v2/passenger/rides/$rideId/payments/status'));
      if (response.statusCode == 200 && mounted) {
        final decoded = jsonDecode(response.body);
        final payload = decoded is Map
            ? Map<String, dynamic>.from(decoded)
            : <String, dynamic>{};
        final payment = PixPaymentData.fromJson(payload);
        setState(() {
          _paymentId = payment.paymentId ?? _paymentId;
          _paymentStatus = payment.status ?? _paymentStatus;
          if (payment.expiresAt != null) {
            _paymentExpiresAt = payment.expiresAt;
            if (_paymentExpiresAt != null) {
              _secondsLeft = _paymentExpiresAt!
                  .difference(DateTime.now())
                  .inSeconds
                  .clamp(0, 60 * 60);
            }
          }
        });
        if (payment.isPaid) _completePayment();
        if (showFeedback && !payment.isPaid && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pagamento ainda não identificado.'),
            ),
          );
        }
      }
    } catch (_) {
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível verificar o PIX.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _completePayment() {
    if (!mounted || _didComplete) return;
    _didComplete = true;
    _timer?.cancel();
    Navigator.of(context).pop(true);
  }

  void _retryCreatePayment() {
    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });
    unawaited(_createPayment());
  }

  Widget _buildQrCode() {
    final image = normalizedPixBase64(_encodedImage);
    if (image == null) {
      return Center(
        child: _isCreating
            ? const CircularProgressIndicator(color: Color(0xFFC92D7A))
            : const Icon(
                Icons.qr_code_2_rounded,
                color: Color(0xFF94A3B8),
                size: 90,
              ),
      );
    }
    try {
      return Image.memory(base64Decode(image), fit: BoxFit.contain);
    } catch (_) {
      return const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Color(0xFF94A3B8),
          size: 64,
        ),
      );
    }
  }

  Future<void> _expirePayment() async {
    final rideId = widget.rideId ?? widget.rideArgs?.existingRideId;
    if (rideId == null || rideId.trim().isEmpty) return;

    try {
      await _api.post(Uri.parse('v2/passenger/rides/$rideId/payments/cancel'));
    } catch (_) {
      // O job do backend continua sendo a fonte de verdade para a expiração.
    }
    await _refreshPaymentStatus();
  }

  // ==== MÉTODO PARA RENDERIZAR A TELA DE ERRO ====
  Widget _buildErrorScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Pagamento PIX',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Área superior rolável
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFCE7F3), // Fundo rosinha claro
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          color: Color(0xFFC92D7A),
                          size: 48,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.payments_outlined,
                          color: Color(0xFFC92D7A),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Pagamento não identificado',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Não conseguimos confirmar o recebimento do\nseu PIX. O tempo limite pode ter expirado ou\nhouve um problema na transação.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2F8), // Fundo mais claro
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Verifique se o valor foi debitado da sua conta\nantes de tentar novamente.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475467),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Área dos botões (fixa na parte inferior, otimizada)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, bottom: 16, top: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ocupa apenas o necessário
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => PixPaymentPage(
                              amount: widget.amount,
                              rideArgs: widget.rideArgs,
                              rideId: widget.rideId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: Text(
                        'Tentar Novamente',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC92D7A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.account_balance_wallet_outlined,
                          color: Color(0xFFC92D7A)),
                      label: Text(
                        'Trocar Forma de Pagamento',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC92D7A),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFFBCFE8), width: 1.5),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Precisa de ajuda? Fale com o suporte',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFFC92D7A),
        unselectedItemColor: const Color(0xFF94A3B8),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 10, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 10, fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'INÍCIO'),
          BottomNavigationBarItem(
              icon: Icon(Icons.directions_car_outlined), label: 'VIAGENS'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'PAGAMENTO'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'PERFIL'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.paymentFailed || _paymentClosed) {
      return _buildErrorScreen(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Pagamento via PIX',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Área superior rolável
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 24, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC92D7A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.money,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'VALOR DA SUA CORRIDA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${widget.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Container(
                            height: 170,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F9FC),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFEFF3F8)),
                            ),
                            child: _buildQrCode(),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Este código expira em:',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _timerLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFC92D7A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _pixCode == null ? null : _copyPixCode,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _pixCode ?? 'Gerando código PIX...',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF475467),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC92D7A),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: _isCreating
                                        ? const Padding(
                                            padding: EdgeInsets.all(10),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.copy,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFFB91C1C),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _isCreating
                                        ? null
                                        : _retryCreatePayment,
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Tentar gerar novamente'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Área dos botões fixa na parte inferior otimizada e sem quebrar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 16, top: 12),
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Garante que a coluna tenha a menor altura possível
                children: [
                  Container(
                    width: double.infinity,
                    height: 56,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEFF2FF),
                        foregroundColor: const Color(0xFF667085),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        _isPaid
                            ? 'Pagamento identificado'
                            : _isCreating
                                ? 'Gerando cobrança PIX...'
                                : 'Aguardando pagamento...',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _pixCode == null || _isRefreshing
                          ? null
                          : () => _refreshPaymentStatus(showFeedback: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPaid
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFC92D7A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isRefreshing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isPaid
                                  ? 'Pagamento confirmado'
                                  : 'Já paguei · Verificar agora',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
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
