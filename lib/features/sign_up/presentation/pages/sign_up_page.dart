import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/core/di/auth_module.dart';
import 'package:tmjapp/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:tmjapp/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:tmjapp/features/sign_up/presentation/controllers/sign_up_controller.dart';
import 'package:tmjapp/features/sign_up/presentation/controllers/sign_up_state.dart';
import 'package:tmjapp/features/sign_up/presentation/widgets/sign_up_terms_checkbox.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final SignUpController _controller;
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );
  String? _lastErrorMessage;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    final repository = createAuthRepository();
    _controller = SignUpController(
      signUpUseCase: SignUpUseCase(repository),
    )..addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onStateChanged)
      ..dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final state = _controller.state;
    _syncController(_fullNameController, state.fullName);
    _syncController(_emailController, state.email);
    _syncController(_phoneController, state.phone);
    _syncController(_passwordController, state.password);
    _syncController(_confirmPasswordController, state.confirmPassword);

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

    if (state.didSignUp && !_hasNavigated) {
      _hasNavigated = true;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.dashboard,
        (route) => false,
      );
    }
  }

  void _syncController(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return _SignUpContent(
              state: _controller.state,
              fullNameController: _fullNameController,
              emailController: _emailController,
              phoneController: _phoneController,
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              phoneMask: _phoneMask,
              onBack: () => _goToSignIn(context),
              onFullNameChanged: _controller.updateFullName,
              onEmailChanged: _controller.updateEmail,
              onPhoneChanged: _controller.updatePhone,
              onPasswordChanged: _controller.updatePassword,
              onConfirmPasswordChanged: _controller.updateConfirmPassword,
              onAcceptedTermsChanged: _controller.toggleAcceptedTerms,
              onSignUp: _controller.signUp,
              onGoToSignIn: () => _goToSignIn(context),
            );
          },
        ),
      ),
    );
  }

  void _goToSignIn(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
  }
}

class _SignUpContent extends StatefulWidget {
  const _SignUpContent({
    required this.state,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.phoneMask,
    required this.onBack,
    required this.onFullNameChanged,
    required this.onEmailChanged,
    required this.onPhoneChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    required this.onAcceptedTermsChanged,
    required this.onSignUp,
    required this.onGoToSignIn,
  });

  final SignUpState state;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final MaskTextInputFormatter phoneMask;
  final VoidCallback onBack;
  final ValueChanged<String> onFullNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;
  final ValueChanged<bool> onAcceptedTermsChanged;
  final VoidCallback onSignUp;
  final VoidCallback onGoToSignIn;

  @override
  State<_SignUpContent> createState() => _SignUpContentState();
}

class _SignUpContentState extends State<_SignUpContent> {
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                color: const Color(0xFF111827),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 10),
              Text(
                'Criar Conta',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 24),
          Text(
            'Comece sua jornada',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
              letterSpacing: -1.4,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preencha os dados abaixo para se cadastrar na TMJApp.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF667085),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),
          const _FieldLabel('Nome Completo'),
          const SizedBox(height: 10),
          AuthInputField(
            controller: widget.fullNameController,
            hintText: 'Digite seu nome completo',
            icon: Icons.person_rounded,
            onChanged: widget.onFullNameChanged,
          ),
          const SizedBox(height: 18),
          const _FieldLabel('E-mail'),
          const SizedBox(height: 10),
          AuthInputField(
            controller: widget.emailController,
            hintText: 'exemplo@email.com',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            onChanged: widget.onEmailChanged,
          ),
          const SizedBox(height: 18),
          const _FieldLabel('Numero de Telefone'),
          const SizedBox(height: 10),
          TextField(
            controller: widget.phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [widget.phoneMask],
            onChanged: widget.onPhoneChanged,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
            decoration: _fieldDecoration(
              hintText: '(00) 00000-0000',
              icon: Icons.call_rounded,
            ),
          ),
          const SizedBox(height: 18),
          const _FieldLabel('Senha'),
          const SizedBox(height: 10),
          TextField(
            controller: widget.passwordController,
            obscureText: _hidePassword,
            onChanged: widget.onPasswordChanged,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
            decoration: _fieldDecoration(
              hintText: 'Crie uma senha forte',
              icon: Icons.lock_rounded,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF98A2B3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _FieldLabel('Confirmar Senha'),
          const SizedBox(height: 10),
          TextField(
            controller: widget.confirmPasswordController,
            obscureText: _hideConfirmPassword,
            onChanged: widget.onConfirmPasswordChanged,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
            decoration: _fieldDecoration(
              hintText: 'Repita sua senha',
              icon: Icons.lock_reset_rounded,
              suffixIcon: IconButton(
                onPressed: () => setState(
                  () => _hideConfirmPassword = !_hideConfirmPassword,
                ),
                icon: Icon(
                  _hideConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF98A2B3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SignUpTermsCheckbox(
            value: widget.state.acceptedTerms,
            onChanged: widget.onAcceptedTermsChanged,
          ),
          const SizedBox(height: 28),
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
                onPressed: widget.state.isLoading ? null : widget.onSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: widget.state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Criar minha conta',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Center(
            child: Text.rich(
              TextSpan(
                text: 'Ja tem uma conta? ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF667085),
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: widget.onGoToSignIn,
                      child: Text(
                        'Entre aqui',
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
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: const Color(0xFF98A2B3),
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: const Color(0xFF98A2B3)),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFDDE3EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFC72F79)),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF344054),
      ),
    );
  }
}
