import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todaybread/models/review/boss_review_response.dart';
import 'package:todaybread/models/review/my_review_response.dart';
import 'package:todaybread/models/review/review_create_response.dart';
import 'package:todaybread/models/review/store_review_response.dart';
import 'package:todaybread/services/network/dio_client.dart';
import 'package:todaybread/services/network/multipart_image_helper.dart';
import 'package:todaybread/services/review/review_api.dart';

class ReviewService {
  ReviewService._();

  static final ReviewService instance = ReviewService._();

  final ReviewApi _api = ReviewApi(DioClient.instance);

  Future<StoreReviewPageResponse> getStoreReviews({
    required int storeId,
    String sort = 'LATEST',
    int page = 0,
    int size = 20,
  }) async {
    final data = await _api.getStoreReviews(
      storeId: storeId,
      sort: sort,
      page: page,
      size: size,
    );
    return StoreReviewPageResponse.fromJson(Map<String, dynamic>.from(data));
  }

  Future<BossReviewPageResponse> getBossReviews({
    String sort = 'LATEST',
    String filter = 'ALL',
    int page = 0,
    int size = 20,
  }) async {
    final data = await _api.getBossReviews(
      sort: sort,
      filter: filter,
      page: page,
      size: size,
    );
    return BossReviewPageResponse.fromJson(Map<String, dynamic>.from(data));
  }

  Future<MyReviewPageResponse> getMyReviews({
    String sort = 'LATEST',
    int page = 0,
    int size = 100,
  }) async {
    final data = await _api.getMyReviews(sort: sort, page: page, size: size);
    return MyReviewPageResponse.fromJson(Map<String, dynamic>.from(data));
  }

  Future<ReviewCreateResponse> createReview({
    required int orderItemId,
    required int rating,
    required String content,
    required List<XFile> images,
  }) async {
    final formData = FormData();
    formData.files.add(
      MapEntry(
        'request',
        MultipartFile.fromString(
          jsonEncode({
            'orderItemId': orderItemId,
            'rating': rating,
            'content': content,
          }),
          filename: 'request.json',
          contentType: MediaType('application', 'json'),
        ),
      ),
    );

    for (final image in images.take(2)) {
      formData.files.add(
        MapEntry('images', await MultipartImageHelper.fromXFile(image)),
      );
    }

    final data = await _api.createReview(formData);
    return ReviewCreateResponse.fromJson(Map<String, dynamic>.from(data));
  }
}
