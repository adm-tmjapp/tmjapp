import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/core/di/auth_module.dart';
import 'package:tmjapp/utils/strings.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _repository = createAuthRepository();
  String? _email;
  bool _codeSent = false;
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _email = preferences.getString(Strings.prefEmail));
  }

  String _message(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  Future<void> _sendCode() async {
    final email = _email?.trim() ?? '';
    if (email.isEmpty) {
      _show('Não foi possível identificar o e-mail da sua conta.');
      return;
    }
    setState(() => _loading = true);
    try {
      await _repository.requestPasswordReset(email);
      if (!mounted) return;
      setState(() => _codeSent = true);
      _show('Enviamos um código de verificação para $email.');
    } catch (error) {
      if (mounted) _show(_message(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await _repository.verifyPasswordResetCode(
        email: _email!,
        code: _codeController.text.trim(),
      );
      await _repository.resetPassword(
        email: _email!,
        code: _codeController.text.trim(),
        newPassword: _passwordController.text,
      );
      await _repository.updateRememberedPassword(_passwordController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) _show(_message(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar senha')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              _codeSent
                  ? 'Digite o código recebido e escolha sua nova senha.'
                  : 'Por segurança, enviaremos um código para o e-mail cadastrado${_email == null ? '.' : ':\n$_email'}',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 28),
            if (!_codeSent)
              _ActionButton(
                label: 'ENVIAR CÓDIGO',
                loading: _loading,
                onPressed: _sendCode,
              )
            else
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Código de verificação',
                        prefixIcon: Icon(Icons.pin_outlined),
                      ),
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'Informe o código recebido.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
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
                      decoration: const InputDecoration(
                        labelText: 'Confirmar nova senha',
                        prefixIcon: Icon(Icons.lock_reset_outlined),
                      ),
                      validator: (value) => value != _passwordController.text
                          ? 'As senhas não conferem.'
                          : null,
                    ),
                    const SizedBox(height: 28),
                    _ActionButton(
                      label: 'ALTERAR SENHA',
                      loading: _loading,
                      onPressed: _changePassword,
                    ),
                    TextButton(
                      onPressed: _loading ? null : _sendCode,
                      child: const Text('Reenviar código'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC92D7A),
          foregroundColor: Colors.white,
        ),
        child: loading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
