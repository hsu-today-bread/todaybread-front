import 'package:todaybread/models/bread/bread_common_response.dart';
import 'package:todaybread/models/store/store_common_response.dart';
import 'package:todaybread/models/store/store_image_response.dart';

enum StoreSellingStatus {
  selling,
  openSoldOut,
  closed;

  static StoreSellingStatus fromJson(String? value, {required bool isSelling}) {
    switch (value) {
      case 'SELLING':
        return StoreSellingStatus.selling;
      case 'OPEN_SOLD_OUT':
        return StoreSellingStatus.openSoldOut;
      case 'CLOSED':
        return StoreSellingStatus.closed;
      default:
        return isSelling
            ? StoreSellingStatus.selling
            : StoreSellingStatus.closed;
    }
  }
}

class StoreDetailResponse {
  final StoreCommonResponse store;
  final List<StoreImageResponse> images;
  final List<BreadCommonResponse> breads;
  final bool isSelling;
  final StoreSellingStatus sellingStatus;
  final double averageRating;
  final int reviewCount;

  const StoreDetailResponse({
    required this.store,
    required this.images,
    required this.breads,
    required this.isSelling,
    required this.sellingStatus,
    required this.averageRating,
    required this.reviewCount,
  });

  factory StoreDetailResponse.fromJson(Map<String, dynamic> json) {
    final isSelling = json['isSelling'] as bool? ?? false;
    return StoreDetailResponse(
      store: StoreCommonResponse.fromJson(
        json['store'] as Map<String, dynamic>,
      ),
      images:
          (json['images'] as List<dynamic>? ?? [])
              .map(
                (value) =>
                    StoreImageResponse.fromJson(value as Map<String, dynamic>),
              )
              .toList()
            ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
      breads: (json['breads'] as List<dynamic>? ?? [])
          .map(
            (value) =>
                BreadCommonResponse.fromJson(value as Map<String, dynamic>),
          )
          .toList(),
      isSelling: isSelling,
      sellingStatus: StoreSellingStatus.fromJson(
        json['sellingStatus'] as String?,
        isSelling: isSelling,
      ),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }
}
