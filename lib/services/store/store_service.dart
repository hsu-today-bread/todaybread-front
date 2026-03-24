import 'package:todaybread/models/store/store_common_request.dart';
import 'package:todaybread/models/store/store_common_response.dart';
import 'package:todaybread/models/store/store_status_response.dart';
import 'package:todaybread/services/network/dio_client.dart';
import 'package:todaybread/services/store/store_api.dart';

/// 가게 도메인 서비스입니다.
class StoreService {
  StoreService._();

  static final StoreService instance = StoreService._();

  final StoreApi _api = StoreApi(DioClient.instance);

  Future<StoreStatusResponse> getStatus() async {
    return await _api.getStatus();
  }

  Future<StoreCommonResponse> createStore(StoreCommonRequest request) async {
    return await _api.createStore(request);
  }

  Future<StoreCommonResponse> updateStore(StoreCommonRequest request) async {
    return await _api.updateStore(request);
  }
}
