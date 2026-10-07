import 'package:flutter/material.dart';

class TmjSplashBrand extends StatelessWidget {
  const TmjSplashBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(
            'assets/branding/app_icon_passenger.png',
            width: 132,
            height: 132,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
