import 'package:flutter/material.dart';
import 'package:todaybread/utils/app_colors.dart';
import 'package:todaybread/widgets/pressable.dart';
import 'package:todaybread/widgets/app_network_image.dart';

class BreadListCard extends StatelessWidget {
  const BreadListCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.distanceText,
    required this.salePrice,
    required this.originalPrice,
    required this.remainingTimeText,
    required this.onTap,
    this.storeName,
    this.discountPercent,
    this.isSoldOut = false,
    this.ratingText,
  });

  final String name;
  final String? imageUrl;
  final String distanceText;
  final int salePrice;
  final int originalPrice;
  final String remainingTimeText;
  final String? storeName;
  final int? discountPercent;
  final bool isSoldOut;
  final String? ratingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Opacity(
          opacity: isSoldOut ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(),
                const SizedBox(width: 14),
                Expanded(child: _buildInfo()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 좌측 썸네일 (품절 시 오버레이)
  Widget _buildThumbnail() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 96,
            height: 96,
            color: AppColors.surface,
            child: AppNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: const Center(
                child: Icon(
                  Icons.bakery_dining_rounded,
                  size: 36,
                  color: Color(0xFFC0A589),
                ),
              ),
            ),
          ),
        ),
        if (isSoldOut)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  '품절',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 우측 정보 영역
  Widget _buildInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상품명 + 별점
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.28,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (ratingText != null) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.star_rounded,
                size: 15,
                color: Color(0xFFFFB400),
              ),
              const SizedBox(width: 2),
              Text(
                ratingText!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),

        // 가게명 · 거리
        Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                storeName != null ? '$storeName · $distanceText' : distanceText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 할인율 배지 + 가격 + 원가
        Row(
          children: [
            if (discountPercent != null && discountPercent! > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.dealBadgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$discountPercent%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dealBadgeText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              '${_formatPrice(salePrice)}원',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.dealPrice,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${_formatPrice(originalPrice)}원',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textHint,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 남은 시간 칩
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 13,
                color: AppColors.surfaceMutedText,
              ),
              const SizedBox(width: 5),
              Text(
                remainingTimeText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.surfaceMutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatPrice(int price) {
    final text = price.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;
      buffer.write(text[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}
