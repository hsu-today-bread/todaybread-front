import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todaybread/models/bread/bread_common_request.dart';
import 'package:todaybread/models/bread/bread_common_response.dart';
import 'package:todaybread/models/bread/bread_detail_response.dart';
import 'package:todaybread/models/bread/nearyby_bread_response.dart';
import 'package:todaybread/services/bread/bread_api.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/network/dio_client.dart';
import 'package:todaybread/services/network/multipart_image_helper.dart';

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
    if (image == null) {
      throw ApiException(message: '상품 사진을 등록해주세요.');
    }

    final formData = FormData();
    formData.files.add(
      MapEntry(
        'request',
        MultipartFile.fromString(
          jsonEncode(request.toJson()),
          filename: 'request.json',
          contentType: MediaType('application', 'json'),
        ),
      ),
    );
    formData.files.add(
      MapEntry('image', await MultipartImageHelper.fromXFile(image)),
    );

    final response = await DioClient.instance.post<Map<String, dynamic>>(
      '/api/boss/bread',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return BreadCommonResponse.fromJson(response.data!);
  }

  Future<BreadCommonResponse> updateBread({
    required int breadId,
    required BreadCommonRequest request,
    XFile? image,
  }) async {
    final formData = FormData();
    formData.files.add(
      MapEntry(
        'request',
        MultipartFile.fromString(
          jsonEncode(request.toJson()),
          filename: 'request.json',
          contentType: MediaType('application', 'json'),
        ),
      ),
    );
    if (image != null) {
      formData.files.add(
        MapEntry('image', await MultipartImageHelper.fromXFile(image)),
      );
    }

    final response = await DioClient.instance.put<Map<String, dynamic>>(
      '/api/boss/bread/$breadId',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return BreadCommonResponse.fromJson(response.data!);
  }

  Future<void> updateBreadStock({
    required int breadId,
    required int remainingQuantity,
  }) async {
    await _api.updateBreadStock(breadId, {
      'remainingQuantity': remainingQuantity,
    });
  }

  Future<void> deleteBread(int breadId) async {
    await _api.deleteBread(breadId);
  }
}
