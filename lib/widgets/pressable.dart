import 'package:flutter/material.dart';

/// 누르는 동안 살짝 작아졌다가 떼면 돌아오는 탭 피드백 위젯입니다.
///
/// 토스처럼 "눌리는" 촉감을 주기 위해 [scaleDown]만큼 축소합니다.
/// 카드·버튼·칩 등 탭 가능한 요소를 감싸 사용하세요.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleDown = 0.97,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// 눌렀을 때 줄어드는 비율 (0.97 = 3% 축소)
  final double scaleDown;

  /// 둥근 모서리 클리핑이 필요할 때 지정합니다.
  final BorderRadius? borderRadius;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = AnimatedScale(
      scale: _pressed ? widget.scaleDown : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: widget.child,
    );

    if (widget.borderRadius != null) {
      child = ClipRRect(borderRadius: widget.borderRadius!, child: child);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: child,
    );
  }
}
