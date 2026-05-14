import 'package:dio/dio.dart';

class ReviewApi {
  const ReviewApi(this._dio);

  final Dio _dio;

  Future<dynamic> getStoreReviews({
    required int storeId,
    required String sort,
    required int page,
    required int size,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/review/store/$storeId',
      queryParameters: {'sort': sort, 'page': page, 'size': size},
    );
    return response.data;
  }

  Future<dynamic> getBossReviews({
    required String sort,
    required String filter,
    required int page,
    required int size,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/boss/review',
      queryParameters: {
        'sort': sort,
        'filter': filter,
        'page': page,
        'size': size,
      },
    );
    return response.data;
  }

  Future<dynamic> getMyReviews({
    required String sort,
    required int page,
    required int size,
  }) async {
    final response = await _dio.get<dynamic>(
      '/api/review/my',
      queryParameters: {'sort': sort, 'page': page, 'size': size},
    );
    return response.data;
  }

  Future<dynamic> createReview(FormData formData) async {
    final response = await _dio.post<dynamic>(
      '/api/review',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return response.data;
  }
}
