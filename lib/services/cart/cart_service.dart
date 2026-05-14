import 'package:todaybread/models/cart/cart_add_request.dart';
import 'package:todaybread/models/cart/cart_response.dart';
import 'package:todaybread/models/cart/cart_update_request.dart';
import 'package:todaybread/services/network/dio_client.dart';

import 'cart_api.dart';

class CartService {
  CartService._();

  static final CartService instance = CartService._();

  final CartApi _api = CartApi(DioClient.instance);

  Future<CartResponse> getCart() => _api.getCart();

  Future<void> addItem(int breadId, int quantity) =>
      _api.addItem(CartAddRequest(breadId: breadId, quantity: quantity));

  Future<void> updateItem(int cartItemId, int quantity) =>
      _api.updateItem(cartItemId, CartUpdateRequest(quantity: quantity));

  Future<void> deleteItem(int cartItemId) => _api.deleteItem(cartItemId);

  Future<void> clearCart() => _api.clearCart();
}
