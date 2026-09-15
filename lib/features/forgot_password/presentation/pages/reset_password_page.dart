import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/core/di/auth_module.dart';
import 'package:tmjapp/features/forgot_password/data/password_reset_local_data_source.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, this.email});

  final String? email;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _repository = createAuthRepository();
  final _localDataSource = PasswordResetLocalDataSource();
  String? _email;
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _email = widget.email?.trim().toLowerCase();
    if (_email == null || _email!.isEmpty) _loadPendingEmail();
  }

  Future<void> _loadPendingEmail() async {
    final email = await _localDataSource.getPendingEmail();
    if (!mounted) return;
    if (email == null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.forgotPassword);
      return;
    }
    setState(() => _email = email);
  }

  String _message(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  void _show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false) || _email == null) return;
    setState(() => _loading = true);
    try {
      final code = _codeController.text.trim();
      // O endpoint de redefinição já valida o código no servidor. Fazer uma
      // chamada de verificação separada pode invalidar o fluxo quando o
      // código é consumido/atualizado entre as duas requisições. O App Drive
      // usa o mesmo fluxo direto e funciona corretamente.
      await _repository.resetPassword(
        email: _email!,
        code: code,
        newPassword: _passwordController.text,
      );
      await _localDataSource.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Senha redefinida com sucesso. Faça login.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.signIn,
        (route) => false,
      );
    } catch (error) {
      if (mounted) _show(_message(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    if (_email == null || _loading) return;
    setState(() => _loading = true);
    try {
      await _repository.requestPasswordReset(_email!);
      if (mounted) _show('Enviamos um novo código para $_email.');
    } catch (error) {
      if (mounted) _show(_message(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _localDataSource.clear();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F6),
        appBar: AppBar(
          title: const Text('Redefinir senha'),
          backgroundColor: const Color(0xFFF8F6F6),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Digite o código de 6 dígitos enviado para ${_email ?? 'seu e-mail'} e escolha uma nova senha.',
                  style: GoogleFonts.publicSans(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Código de verificação',
                    prefixIcon: Icon(Icons.pin_outlined),
                    counterText: '',
                  ),
                  validator: (value) => value?.trim().length != 6
                      ? 'Informe o código de 6 dígitos.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Nova senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                      icon: Icon(_hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                    ),
                  ),
                  validator: (value) => (value?.length ?? 0) < 6
                      ? 'Use pelo menos 6 caracteres.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _resetPassword(),
                  decoration: const InputDecoration(
                    labelText: 'Confirmar nova senha',
                    prefixIcon: Icon(Icons.lock_reset_outlined),
                  ),
                  validator: (value) => value != _passwordController.text
                      ? 'As senhas não conferem.'
                      : null,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _loading || _email == null ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC92D7A),
                      foregroundColor: Colors.white,
                    ),
                    child: _loading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('REDEFINIR SENHA'),
                  ),
                ),
                TextButton(
                  onPressed: _loading ? null : _resendCode,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Reenviar código'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
