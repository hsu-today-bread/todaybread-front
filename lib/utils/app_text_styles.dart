import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 앱 전역에서 재사용하는 텍스트 스타일 상수 모음입니다.
class AppTextStyles {
  /// 외부 생성 방지를 위한 private 생성자입니다.
  AppTextStyles._();

  /// 스플래시 타이틀 스타일
  static const TextStyle splashTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.titleText,
    height: 1.2,
  );

  /// 스플래시 서브타이틀 스타일
  static const TextStyle splashSubtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.subtitleText,
    height: 1.4,
  );

  /// 온보딩 안내 문구 스타일
  static const TextStyle onboardingMessage = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
    height: 1.3,
  );

  /// 시작 버튼 텍스트 스타일
  static const TextStyle startButton = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  /// 앱바 타이틀 텍스트 스타일
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  /// 폼 라벨 텍스트 스타일
  static const TextStyle formLabel = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  /// 폼 힌트 텍스트 스타일
  static const TextStyle formHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFFBDBDBD),
  );

  /// 중복확인 버튼 텍스트 스타일
  static const TextStyle duplicateCheckButton = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  /// 보조 설명(캡션) 텍스트 스타일
  static const TextStyle helperCaption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  /// 주요 액션 버튼 텍스트 스타일
  static const TextStyle primaryAction = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );
}
