import 'package:todaybread/models/keyword/keyword_response.dart';
import 'package:todaybread/models/store/favourite_store_response.dart';

class WishlistResponse {
  final List<KeywordResponse> keywords;
  final List<FavouriteStoreResponse> favouriteStores;

  const WishlistResponse({
    required this.keywords,
    required this.favouriteStores,
  });

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    return WishlistResponse(
      keywords: (json['keywords'] as List<dynamic>? ?? [])
          .map((e) => KeywordResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      favouriteStores: (json['favouriteStores'] as List<dynamic>? ?? [])
          .map((e) => FavouriteStoreResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
