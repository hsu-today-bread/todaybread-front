import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:todaybread/models/wishlist/wishlist_response.dart';

part 'wishlist_api.g.dart';

@RestApi()
abstract class WishlistApi {
  factory WishlistApi(Dio dio, {String baseUrl}) = _WishlistApi;

  @GET('/api/wishlist')
  Future<WishlistResponse> getWishlist();
}
