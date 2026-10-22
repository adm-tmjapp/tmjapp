import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/api/auth_api.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:tmjapp/features/auth/domain/entities/auth_session.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key, required this.session});

  final AuthSession session;

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  static const _resendDelay = Duration(seconds: 60);
  final _codeController = TextEditingController();
  final _authApi = Authapi();
  final _localDataSource = AuthLocalDataSource();
  Timer? _resendTimer;
  int _resendSeconds = 0;
  bool _isSending = false;
  bool _isVerifying = false;
  bool _didSendInitialCode = false;
  String? _error;
  String? _notice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendCode());
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_isSending || _resendSeconds > 0) return;
    setState(() {
      _isSending = true;
      _error = null;
      _notice = null;
    });
    try {
      await _authApi.sendEmailVerificationCode();
      if (!mounted) return;
      setState(() {
        _didSendInitialCode = true;
        _notice = 'Enviamos um código de confirmação para seu e-mail.';
      });
      _startResendCooldown();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _message(error, 'Não foi possível enviar o código.');
      });
      // Evita tentativas repetidas em sequência mesmo quando o servidor falha.
      _startResendCooldown();
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = _resendDelay.inSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6 || _isVerifying) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isVerifying = true;
      _error = null;
      _notice = null;
    });
    try {
      await _authApi.verifyEmailVerificationCode(code);
      await _localDataSource.markEmailVerified();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.dashboard,
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _message(error, 'Código inválido ou expirado.');
      });
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  String _message(Object error, String fallback) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty ? fallback : message;
  }

  String get _maskedEmail {
    final email = widget.session.email?.trim() ?? '';
    final parts = email.split('@');
    if (parts.length != 2 || parts.first.length < 2) {
      return 'seu e-mail cadastrado';
    }
    return '${parts.first.substring(0, 2)}•••@${parts.last}';
  }

  @override
  Widget build(BuildContext context) {
    final canVerify = _codeController.text.trim().length == 6 && !_isVerifying;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.signIn,
            (route) => false,
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Confirmar e-mail',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF111827),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 64,
                    color: Color(0xFFC92D7A),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Verifique seu e-mail',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF111827),
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Digite o código de 6 dígitos enviado para $_maskedEmail. A confirmação libera o acesso à sua conta.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF667085),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF111827),
                      fontSize: 24,
                      letterSpacing: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: '••••••',
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    _FeedbackText(text: _error!, isError: true),
                  if (_notice != null)
                    _FeedbackText(text: _notice!, isError: false),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: canVerify ? _verifyCode : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC92D7A),
                        disabledBackgroundColor: const Color(0xFFE8A7C6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isVerifying
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Confirmar e continuar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isSending || _resendSeconds > 0
                        ? null
                        : () => _sendCode(),
                    child: Text(
                      _isSending
                          ? 'Enviando código...'
                          : _resendSeconds > 0
                              ? 'Reenviar em 00:${_resendSeconds.toString().padLeft(2, '0')}'
                              : _didSendInitialCode
                                  ? 'Reenviar código'
                                  : 'Enviar código',
                      style: const TextStyle(color: Color(0xFFC92D7A)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Se não encontrar a mensagem, confira também a pasta de spam.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF98A2B3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackText extends StatelessWidget {
  const _FeedbackText({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isError ? const Color(0xFFB42318) : const Color(0xFF027A48),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
