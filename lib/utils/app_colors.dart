import 'package:flutter/material.dart';

/// 앱 전역에서 재사용하는 색상 상수 모음입니다.
class AppColors {
  /// 외부 생성 방지를 위한 private 생성자입니다.
  AppColors._();

  /// 주요 배경색(브랜드 메인 컬러)
  static const Color primaryBackground = Color(0xFF55433C);

  /// 기본 흰색
  static const Color white = Colors.white;

  /// 기본 검정색
  static const Color black = Colors.black;

  /// 타이틀 텍스트 색상
  static const Color titleText = Colors.black;

  /// 서브타이틀 텍스트 색상
  static const Color subtitleText = Colors.black87;
}
