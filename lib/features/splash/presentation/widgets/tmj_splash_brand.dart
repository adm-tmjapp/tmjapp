import 'package:flutter/material.dart';

class TmjSplashBrand extends StatelessWidget {
  const TmjSplashBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final logoSize = (constraints.maxWidth * 0.56).clamp(132.0, 184.0);

        return Semantics(
          container: true,
          label: 'TMJApp',
          child: Image.asset(
            'assets/branding/tmj_logo_correct.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}
