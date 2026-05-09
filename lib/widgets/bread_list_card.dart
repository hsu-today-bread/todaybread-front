import 'package:flutter/material.dart';
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
          child: Opacity(
            opacity: isSoldOut ? 0.5 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 106,
                          height: 106,
                          color: const Color(0xFFF4EEE7),
                          child: AppNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: const Center(
                              child: Icon(
                                Icons.bakery_dining,
                                size: 38,
                                color: Color(0xFFB28B67),
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
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                '품절',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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
                            if (ratingText != null) ...[
                              const SizedBox(width: 8),
                              const Text('⭐', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 4),
                              Text(
                                ratingText!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7E746A),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (storeName != null) ...[
                          Text(
                            storeName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7E746A),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
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
                            if (discountPercent != null &&
                                discountPercent! > 0) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE65A44),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$discountPercent%',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              '${_formatPrice(salePrice)}원',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE65A44),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '${_formatPrice(originalPrice)}원',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF9D948A),
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Color(0xFF9D948A),
                                  ),
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
