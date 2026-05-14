import 'package:todaybread/models/store/store_common_response.dart';
import 'package:todaybread/models/store/store_image_response.dart';

class StoreInfoResponse {
  final StoreCommonResponse store;
  final List<StoreImageResponse> images;

  StoreInfoResponse({required this.store, required this.images});

  factory StoreInfoResponse.fromJson(Map<String, dynamic> json) {
    return StoreInfoResponse(
      store: StoreCommonResponse.fromJson(
        json['store'] as Map<String, dynamic>,
      ),
      images: (json['images'] as List<dynamic>? ?? [])
          .map(
            (image) =>
                StoreImageResponse.fromJson(image as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  StoreInfoResponse copyWith({
    StoreCommonResponse? store,
    List<StoreImageResponse>? images,
  }) {
    return StoreInfoResponse(
      store: store ?? this.store,
      images: images ?? this.images,
    );
  }
}
