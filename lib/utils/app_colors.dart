import 'package:flutter/material.dart';

/// 앱 전역에서 재사용하는 색상 상수 모음입니다.
///
/// 색 사용 규칙(중요):
/// - 어두운 색(구조: 앱바, 선택된 탭, 강조 버튼 등)은 [brandBrown] 하나로 통일합니다.
/// - 빨강([dealPrice]/[dealBadgeBg])은 "딜" 신호 전용입니다.
///   가격·할인율·마감 임박처럼 사용자가 놓치면 안 되는 정보에만 아껴 씁니다.
/// - 그 외 텍스트/배경은 회색 단계([textPrimary]~[textHint], [surface] 등)를 씁니다.
class AppColors {
  /// 외부 생성 방지를 위한 private 생성자입니다.
  AppColors._();

  // ── 브랜드 / 구조 색상 ──────────────────────────────
  /// 브랜드 메인 컬러(앱바·선택된 탭·강조 버튼 등 어두운 영역 전반)
  static const Color brandBrown = Color(0xFF55433C);

  /// 기존 코드 호환용 별칭 (= brandBrown)
  static const Color primaryBackground = brandBrown;

  // ── 딜(할인) 강조 색상 ──────────────────────────────
  /// 가격·할인 강조 텍스트 색상
  static const Color dealPrice = Color(0xFFE14B30);

  /// 할인율 배지 배경색(옅은 빨강)
  static const Color dealBadgeBg = Color(0xFFFBE9E5);

  /// 할인율 배지 글자색(진한 빨강)
  static const Color dealBadgeText = Color(0xFFD84A30);

  // ── 텍스트 색상 단계 ────────────────────────────────
  /// 주요 텍스트(상품명 등)
  static const Color textPrimary = Color(0xFF2B2521);

  /// 보조 텍스트(가게명·거리 등)
  static const Color textSecondary = Color(0xFF9A8F84);

  /// 힌트/취소선 등 가장 옅은 텍스트
  static const Color textHint = Color(0xFFBBB1A8);

  // ── 배경 / 표면 색상 ────────────────────────────────
  /// 이미지 자리표시자 등 옅은 표면색
  static const Color surface = Color(0xFFF4EEE7);

  /// 칩/태그 등 보조 배경색
  static const Color surfaceMuted = Color(0xFFF5F0EB);

  /// 칩/태그 위 텍스트 색상
  static const Color surfaceMutedText = Color(0xFF7A6E62);

  // ── 기본 색상 ──────────────────────────────────────
  /// 기본 흰색
  static const Color white = Colors.white;

  /// 기본 검정색
  static const Color black = Colors.black;

  /// 타이틀 텍스트 색상
  static const Color titleText = Colors.black;

  /// 서브타이틀 텍스트 색상
  static const Color subtitleText = Colors.black87;

  // ── 스켈레톤(로딩) ──────────────────────────────────
  /// 스켈레톤 기본 색(베이지 톤 회색)
  static const Color skeletonBase = Color(0xFFEDE7E0);

  /// 스켈레톤 시머 하이라이트 색
  static const Color skeletonHighlight = Color(0xFFF7F2EC);

  // ── 그림자 ─────────────────────────────────────────
  /// 카드용 옅은 그림자(테두리 없이 가볍게 떠 보이게)
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F55433C), // brandBrown 6% 투명도
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
  ];
}
