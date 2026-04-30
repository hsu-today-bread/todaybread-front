import 'package:todaybread/models/wishlist/wishlist_response.dart';
import 'package:todaybread/services/network/dio_client.dart';
import 'package:todaybread/services/wishlist/wishlist_api.dart';

class WishlistService {
  WishlistService._();

  static final WishlistService instance = WishlistService._();

  final WishlistApi _api = WishlistApi(DioClient.instance);

  Future<WishlistResponse> getWishlist() => _api.getWishlist();
}
