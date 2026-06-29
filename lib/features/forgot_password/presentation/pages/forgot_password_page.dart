import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/core/di/auth_module.dart';
import 'package:tmjapp/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:tmjapp/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:tmjapp/features/forgot_password/presentation/controllers/forgot_password_controller.dart';
import 'package:tmjapp/features/forgot_password/presentation/controllers/forgot_password_state.dart';
import 'package:tmjapp/features/forgot_password/presentation/widgets/forgot_password_icon.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final ForgotPasswordController _controller;
  late final TextEditingController _emailController;
  String? _lastErrorMessage;
  bool _successShown = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _controller = ForgotPasswordController(
      RequestPasswordResetUseCase(createAuthRepository()),
    )..addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onStateChanged)
      ..dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final state = _controller.state;

    if (_emailController.text != state.email) {
      _emailController.text = state.email;
    }

    if (state.errorMessage != null &&
        state.errorMessage!.isNotEmpty &&
        state.errorMessage != _lastErrorMessage) {
      _lastErrorMessage = state.errorMessage;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
    }

    if (state.errorMessage == null) {
      _lastErrorMessage = null;
    }

    if (state.didSend && !_successShown) {
      _successShown = true;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Se o e-mail existir, as instruções de recuperação foram enviadas.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 40,
                ),
                child: _ForgotPasswordContent(
                  state: _controller.state,
                  emailController: _emailController,
                  onEmailChanged: _controller.updateEmail,
                  onSubmit: _controller.submit,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ForgotPasswordContent extends StatelessWidget {
  const _ForgotPasswordContent({
    required this.state,
    required this.emailController,
    required this.onEmailChanged,
    required this.onSubmit,
  });

  final ForgotPasswordState state;
  final TextEditingController emailController;
  final ValueChanged<String> onEmailChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
          color: const Color(0xFF111827),
        ),
        const SizedBox(height: 12),
        Text(
          'Esqueceu a senha?',
          style: GoogleFonts.publicSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Insira seu e-mail cadastrado para receber as instruções de recuperação.',
          style: GoogleFonts.publicSans(
            fontSize: 16,
            color: const Color(0xFF667085),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 44),
        const Center(child: ForgotPasswordIcon()),
        const SizedBox(height: 40),
        Text(
          'E-mail',
          style: GoogleFonts.publicSans(
            fontSize: 14,
            color: const Color(0xFF667085),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: AuthInputField(
            controller: emailController,
            hintText: 'E-mail',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            onChanged: onEmailChanged,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFC72F79),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33C72F79),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: state.isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'RECUPERAR SENHA',
                      style: GoogleFonts.publicSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
            },
            child: Text.rich(
              TextSpan(
                text: 'Lembrou a senha? ',
                style: GoogleFonts.publicSans(
                  fontSize: 14,
                  color: const Color(0xFF98A2B3),
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: 'Fazer login',
                    style: GoogleFonts.publicSans(
                      fontSize: 14,
                      color: const Color(0xFFC72F79),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
