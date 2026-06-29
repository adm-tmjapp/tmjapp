import 'package:flutter/material.dart';

class ForgotPasswordIcon extends StatelessWidget {
  const ForgotPasswordIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: const BoxDecoration(
        color: Color(0xFFF4E3EC),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.lock_reset_rounded,
        size: 44,
        color: Color(0xFFC72F79),
      ),
    );
  }
}
