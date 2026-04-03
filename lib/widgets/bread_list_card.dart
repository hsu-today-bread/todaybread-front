import 'package:flutter/material.dart';
import 'package:todaybread/utils/app_assets.dart';
import 'package:todaybread/utils/display_helper.dart';

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
    this.ratingText = '4.8',
  });

  final String name;
  final String? imageUrl;
  final String distanceText;
  final int salePrice;
  final int originalPrice;
  final String remainingTimeText;
  final String ratingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = DisplayHelper.resolveImageUrl(imageUrl);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8E2DB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2D2118),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 106,
                    height: 106,
                    color: const Color(0xFFF4EEE7),
                    child: resolvedImageUrl == null
                        ? const Center(
                            child: Icon(
                              Icons.bakery_dining,
                              size: 38,
                              color: Color(0xFFB28B67),
                            ),
                          )
                        : Image.network(
                            resolvedImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                AppAssets.breadImage,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                height: 1.28,
                                color: Color(0xFF23180F),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('⭐', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(
                            ratingText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7E746A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('📍', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            distanceText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7E746A),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${_formatPrice(salePrice)}원',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE65A44),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '${_formatPrice(originalPrice)}원',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF9D948A),
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Color(0xFF9D948A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F3EE),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '남은 시간 : $remainingTimeText',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5E5245),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
