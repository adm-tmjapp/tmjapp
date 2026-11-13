import 'package:flutter/material.dart';

/// Avatar seguro para o motorista da corrida. Nunca usa imagem demonstrativa:
/// exibe o ícone somente quando a API não disponibiliza uma foto válida.
class DriverAvatar extends StatelessWidget {
  const DriverAvatar({
    super.key,
    required this.photoUrl,
    this.size = 56,
    this.borderRadius,
  });

  final String? photoUrl;
  final double size;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim() ?? '';
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF155E75)],
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
      ),
      child: Icon(Icons.person_rounded, color: Colors.white, size: size * .55),
    );
    if (url.isEmpty) return fallback;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}
