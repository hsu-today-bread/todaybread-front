import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:todaybread/models/bread/bread_common_request.dart';
import 'package:todaybread/models/bread/bread_common_response.dart';
import 'package:todaybread/models/bread/bread_detail_response.dart';
import 'package:todaybread/models/bread/nearyby_bread_response.dart';
import 'package:todaybread/services/bread/bread_api.dart';
import 'package:todaybread/services/network/dio_client.dart';

/// 메뉴 도메인 서비스입니다.
///
/// 화면/provider가 multipart 세부 구현을 몰라도 되도록
/// 요청 DTO와 이미지 파일을 API 스펙에 맞게 변환합니다.
class BreadService {
  BreadService._();

  static final BreadService instance = BreadService._();

  final BreadApi _api = BreadApi(DioClient.instance);

  Future<List<NearbyBreadResponse>> getNearbyBreads({
    required double lat,
    required double lng,
    required int radius,
    required String sort,
  }) async {
    return await _api.getNearbyBreads(lat, lng, radius, sort);
  }

  Future<BreadDetailResponse> getBreadDetail(int breadId) async {
    return await _api.getBreadDetail(breadId);
  }

  Future<List<BreadCommonResponse>> getMyBreads() async {
    return await _api.getMyBreads();
  }

  Future<BreadCommonResponse> createBread(
    BreadCommonRequest request,
    XFile? image,
  ) async {
    final directory = await Directory.systemTemp.createTemp(
      'todaybread_bread_',
    );
    final requestFile = File('${directory.path}/request.json');
    await requestFile.writeAsString(jsonEncode(request.toJson()));

    final imageFile = image == null ? null : File(image.path);

    try {
      return await _api.createBread(requestFile, imageFile);
    } finally {
      if (await requestFile.exists()) {
        await requestFile.delete();
      }
      if (await directory.exists()) {
        await directory.delete();
      }
    }
  }

  Future<void> updateBreadStock({
    required int breadId,
    required int remainingQuantity,
  }) async {
    await _api.updateBreadStock(
      breadId,
      {'remainingQuantity': remainingQuantity},
    );
  }
}
