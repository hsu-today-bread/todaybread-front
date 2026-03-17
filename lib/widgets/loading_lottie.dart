import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class LoadingLottie extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;

  const LoadingLottie({
    super.key,
    required this.assetPath,
    this.width = 50,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      repeat: true,
    );
  }
}