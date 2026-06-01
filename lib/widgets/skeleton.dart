import 'package:flutter/material.dart';
import 'package:todaybread/utils/app_colors.dart';

/// 자식 위젯 트리 위로 부드러운 시머(빛 쓸림) 애니메이션을 입히는 래퍼입니다.
///
/// 내부의 [SkeletonBox]들을 회색 실루엣으로 그려두고, 이 위젯으로 한 번 감싸면
/// 전체에 일관된 시머가 흐릅니다.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            // -1 → 1 로 이동하며 좌→우로 빛이 쓸려 지나가는 그라데이션
            final double slide = _controller.value * 2 - 1;
            return LinearGradient(
              begin: Alignment(-1.0 + slide, 0),
              end: Alignment(1.0 + slide, 0),
              colors: const [
                AppColors.skeletonBase,
                AppColors.skeletonHighlight,
                AppColors.skeletonBase,
              ],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// 스켈레톤의 기본 단위(회색 둥근 박스)입니다.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 12,
    this.radius = 6,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.skeletonBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// 빵 카드 한 장의 로딩 실루엣입니다. ([BreadListCard]의 레이아웃을 본떴습니다.)
///
/// 흰 카드 표면과 그림자는 실제 카드와 동일하게 유지하고,
/// 내부 회색 박스에만 시머가 흐릅니다.
class BreadCardSkeleton extends StatelessWidget {
  const BreadCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Shimmer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 96, height: 96, radius: 16),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: double.infinity, height: 16),
                  SizedBox(height: 10),
                  SkeletonBox(width: 120, height: 13),
                  SizedBox(height: 14),
                  SkeletonBox(width: 100, height: 18),
                  SizedBox(height: 12),
                  SkeletonBox(width: 110, height: 24, radius: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 빵 카드 스켈레톤 [count]장을 그려 주는 리스트입니다.
class BreadListSkeleton extends StatelessWidget {
  const BreadListSkeleton({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, __) => const BreadCardSkeleton(),
    );
  }
}

/// 빵 카드 스켈레톤 [count]장을 스크롤 없이 [Column]으로 쌓아 줍니다.
///
/// 이미 스크롤 중인 [Column]/[SingleChildScrollView] 내부 등
/// 높이가 정해지지 않은 곳에서 [BreadListSkeleton] 대신 안전하게 씁니다.
class BreadCardSkeletonColumn extends StatelessWidget {
  const BreadCardSkeletonColumn({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => const BreadCardSkeleton()),
    );
  }
}

/// 가로로 늘어선 칩(키워드 등)의 로딩 실루엣입니다.
class ChipRowSkeleton extends StatelessWidget {
  const ChipRowSkeleton({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    final widths = [64.0, 48.0, 80.0, 56.0, 72.0, 44.0];
    return Shimmer(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          count,
          (i) => SkeletonBox(
            width: widths[i % widths.length],
            height: 32,
            radius: 999,
          ),
        ),
      ),
    );
  }
}

/// 빵 상세 화면 전체의 로딩 실루엣입니다.
/// 상단 큰 이미지 + 제목 + 매장 행 + 가격 자리를 본뜹니다.
class BreadDetailSkeleton extends StatelessWidget {
  const BreadDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: double.infinity, height: 280, radius: 0),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: double.infinity, height: 26),
                  const SizedBox(height: 10),
                  const SkeletonBox(width: 200, height: 26),
                  const SizedBox(height: 24),
                  Row(
                    children: const [
                      SkeletonBox(width: 58, height: 58, radius: 18),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: 140, height: 15),
                            SizedBox(height: 8),
                            SkeletonBox(width: 90, height: 13),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const SkeletonBox(width: 120, height: 22),
                  const SizedBox(height: 20),
                  const SkeletonBox(width: double.infinity, height: 14),
                  const SizedBox(height: 10),
                  const SkeletonBox(width: double.infinity, height: 14),
                  const SizedBox(height: 10),
                  const SkeletonBox(width: 220, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
