import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle splashTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.titleText,
    height: 1.2,
  );

  static const TextStyle splashSubtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.subtitleText,
    height: 1.4,
  );

  static const TextStyle onboardingMessage = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
    height: 1.3,
  );

  static const TextStyle startButton = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static const TextStyle formLabel = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static const TextStyle formHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFFBDBDBD),
  );

  static const TextStyle duplicateCheckButton = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle helperCaption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  static const TextStyle primaryAction = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );
}
