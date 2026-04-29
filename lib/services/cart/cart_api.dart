import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:todaybread/models/cart/cart_add_request.dart';
import 'package:todaybread/models/cart/cart_response.dart';
import 'package:todaybread/models/cart/cart_update_request.dart';

part 'cart_api.g.dart';

@RestApi()
abstract class CartApi {
  factory CartApi(Dio dio, {String baseUrl}) = _CartApi;

  @GET('/api/cart')
  Future<CartResponse> getCart();

  @POST('/api/cart')
  Future<void> addItem(@Body() CartAddRequest request);

  @PATCH('/api/cart/items/{cartItemId}')
  Future<void> updateItem(
    @Path('cartItemId') int cartItemId,
    @Body() CartUpdateRequest request,
  );

  @DELETE('/api/cart/items/{cartItemId}')
  Future<void> deleteItem(@Path('cartItemId') int cartItemId);

  @DELETE('/api/cart')
  Future<void> clearCart();
}
