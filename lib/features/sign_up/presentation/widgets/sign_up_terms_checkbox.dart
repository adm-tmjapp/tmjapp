import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpTermsCheckbox extends StatelessWidget {
  const SignUpTermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: const Offset(-8, -6),
          child: Checkbox(
            value: value,
            activeColor: const Color(0xFFC72F79),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            onChanged: (newValue) => onChanged(newValue ?? false),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  height: 1.5,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  const TextSpan(
                    text: 'Ao me cadastrar, concordo com os ',
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: InkWell(
                      onTap: onTermsPressed,
                      child: const Text(
                        'Termos de Serviço',
                        style: TextStyle(
                          color: Color(0xFFC72F79),
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFC72F79),
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: ' e com a '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: InkWell(
                      onTap: onPrivacyPressed,
                      child: const Text(
                        'Política de Privacidade',
                        style: TextStyle(
                          color: Color(0xFFC72F79),
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFC72F79),
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
