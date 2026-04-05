import 'package:todaybread/models/bread/bread_common_response.dart';
import 'package:todaybread/models/store/store_common_response.dart';
import 'package:todaybread/models/store/store_image_response.dart';

class StoreDetailResponse {
  final StoreCommonResponse store;
  final List<StoreImageResponse> images;
  final List<BreadCommonResponse> breads;
  final bool isSelling;

  const StoreDetailResponse({
    required this.store,
    required this.images,
    required this.breads,
    required this.isSelling,
  });

  factory StoreDetailResponse.fromJson(Map<String, dynamic> json) {
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
      isSelling: json['isSelling'] as bool? ?? false,
    );
  }
}
