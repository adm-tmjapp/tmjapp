import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/core/di/auth_module.dart';
import 'package:tmjapp/features/auth/domain/usecases/get_biometric_status_usecase.dart';
import 'package:tmjapp/features/auth/domain/usecases/get_remembered_auth_usecase.dart';
import 'package:tmjapp/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:tmjapp/features/auth/domain/usecases/sign_in_with_biometrics_usecase.dart';
import 'package:tmjapp/features/auth/presentation/controllers/sign_in_controller.dart';
import 'package:tmjapp/features/auth/presentation/controllers/sign_in_state.dart';
import 'package:tmjapp/features/auth/presentation/widgets/auth_brand_header.dart';
import 'package:tmjapp/features/auth/presentation/widgets/auth_input_field.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late final SignInController _controller;
  late final TextEditingController _identifierController;
  late final TextEditingController _passwordController;
  String? _lastErrorMessage;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController();
    _passwordController = TextEditingController();
    final repository = createAuthRepository();
    _controller = SignInController(
      getRememberedAuthUseCase: GetRememberedAuthUseCase(
        repository,
      ),
      getBiometricStatusUseCase: GetBiometricStatusUseCase(
        repository,
      ),
      signInUseCase: SignInUseCase(
        repository,
      ),
      signInWithBiometricsUseCase: SignInWithBiometricsUseCase(
        repository,
      ),
    )..addListener(_onStateChanged);

    _controller.initialize();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onStateChanged)
      ..dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final state = _controller.state;

    if (_identifierController.text != state.identifier) {
      _identifierController.text = state.identifier;
    }
    if (_passwordController.text != state.password) {
      _passwordController.text = state.password;
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

    if (state.didLogin && !_hasNavigated) {
      _hasNavigated = true;
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final state = _controller.state;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 52,
                ),
                child: _SignInContent(
                  state: state,
                  identifierController: _identifierController,
                  passwordController: _passwordController,
                  onIdentifierChanged: _controller.updateIdentifier,
                  onPasswordChanged: _controller.updatePassword,
                  onRememberMeChanged: _controller.toggleRememberMe,
                  onSignIn: _controller.signIn,
                  onBiometricSignIn: _controller.signInWithBiometrics,
                  onForgotPassword: () {
                    Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SignInContent extends StatelessWidget {
  const _SignInContent({
    required this.state,
    required this.identifierController,
    required this.passwordController,
    required this.onIdentifierChanged,
    required this.onPasswordChanged,
    required this.onRememberMeChanged,
    required this.onSignIn,
    required this.onBiometricSignIn,
    required this.onForgotPassword,
  });

  final SignInState state;
  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final ValueChanged<String> onIdentifierChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onSignIn;
  final VoidCallback onBiometricSignIn;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        const Center(child: AuthBrandHeader()),
        const SizedBox(height: 40),
        Text(
          'Bem-vindo ao TMJApp',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1F2937),
            letterSpacing: -0.8,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Faça login para continuar sua jornada',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: AuthInputField(
            controller: identifierController,
            hintText: 'E-mail ou telefone',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            onChanged: onIdentifierChanged,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: AuthInputField(
            controller: passwordController,
            hintText: 'Senha',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            onChanged: onPasswordChanged,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: state.rememberMe,
                activeColor: const Color(0xFFC72F79),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onChanged: (value) => onRememberMeChanged(value ?? false),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Lembrar de mim',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onForgotPassword,
              child: Text(
                'Esqueceu a senha?',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFC72F79),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFC72F79),
                  Color(0xFFE04095),
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x52C72F79),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: state.isLoading ? null : onSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
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
                      'ENTRAR',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
        if (state.canUseBiometrics) ...[
          const SizedBox(height: 18),
          Center(
            child: TextButton.icon(
              onPressed: state.isLoading ? null : onBiometricSignIn,
              icon: const Icon(
                Icons.fingerprint_rounded,
                color: Color(0xFFC72F79),
                size: 28,
              ),
              label: Text(
                state.biometricLabel,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFC72F79),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        Center(
          child: Text.rich(
            TextSpan(
              text: 'Não tem uma conta? ',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.signUp);
                    },
                    child: Text(
                      'Cadastre-se',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: const Color(0xFFC72F79),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'POWERED BY TMJ TECHNOLOGY',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
