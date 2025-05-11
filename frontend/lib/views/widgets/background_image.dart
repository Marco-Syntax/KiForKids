import 'package:flutter/material.dart';
import 'dart:ui';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withAlpha(166), BlendMode.darken),
            child: Center(
              child: Image.asset(
                'assets/images/big.png',
                fit: BoxFit.cover,
                color: Colors.black.withAlpha(38),
                colorBlendMode: BlendMode.darken,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
