import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1F2937),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: const Color(0xFF9CA3AF),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFC72F79)),
        ),
      ),
    );
  }
}
