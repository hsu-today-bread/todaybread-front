import 'package:todaybread/models/boss/boss_order_response.dart';
import 'package:todaybread/services/boss/boss_order_api.dart';
import 'package:todaybread/services/network/dio_client.dart';

class BossOrderService {
  BossOrderService._();

  static final BossOrderService instance = BossOrderService._();

  final BossOrderApi _api = BossOrderApi(DioClient.instance);

  Future<BossOrderPageResponse> getOrders({int page = 0, int size = 50}) async {
    final data = await _api.getOrders(page: page, size: size);
    return BossOrderPageResponse.fromDynamic(data);
  }

  Future<void> confirmPickup(int orderId) async {
    await _api.confirmPickup(orderId);
  }
}
