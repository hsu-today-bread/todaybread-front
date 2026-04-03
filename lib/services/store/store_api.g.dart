// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_api.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _StoreApi implements StoreApi {
  _StoreApi(this._dio, {this.baseUrl});

  final Dio _dio;

  String? baseUrl;

  @override
  Future<StoreStatusResponse> getStatus() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<StoreStatusResponse>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/api/boss/store/status',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
      ),
    );
    final value = StoreStatusResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<StoreInfoResponse> getStoreInfo() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<StoreInfoResponse>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/api/boss/store',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
      ),
    );
    final value = StoreInfoResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<StoreDetailResponse> getStoreDetail(int storeId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<StoreDetailResponse>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/api/store/${storeId}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
      ),
    );
    final value = StoreDetailResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<List<FavouriteStoreResponse>> getFavouriteStores() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<FavouriteStoreResponse>>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/api/favourite-stores',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
      ),
    );
    final value = _result.data!
        .map(
          (dynamic i) =>
              FavouriteStoreResponse.fromJson(i as Map<String, dynamic>),
        )
        .toList();
    return value;
  }

  @override
  Future<FavouriteStoreToggleResponse> toggleFavouriteStore(
    Map<String, dynamic> request,
  ) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request);
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<FavouriteStoreToggleResponse>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/api/favourite-stores',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
      ),
    );
    final value = FavouriteStoreToggleResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<StoreInfoResponse> createStore(File request, List<File> images) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.add(
      MapEntry(
        'request',
        MultipartFile.fromFileSync(
          request.path,
          filename: request.path.split(Platform.pathSeparator).last,
          contentType: DioMediaType.parse('application/json'),
        ),
      ),
    );
    _data.files.addAll(
      images.map(
        (i) => MapEntry(
          'images',
          MultipartFile.fromFileSync(
            i.path,
            filename: i.path.split(Platform.pathSeparator).last,
          ),
        ),
      ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<StoreInfoResponse>(
        Options(
              method: 'POST',
              headers: _headers,
              extra: _extra,
              contentType: 'multipart/form-data',
            )
            .compose(
              _dio.options,
              '/api/boss/store',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
      ),
    );
    final value = StoreInfoResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<StoreCommonResponse> updateStore(Map<String, dynamic> request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request);
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<StoreCommonResponse>(
        Options(method: 'PUT', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/api/boss/store',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
      ),
    );
    final value = StoreCommonResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<List<StoreImageResponse>> updateImages(List<File> images) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.addAll(
      images.map(
        (i) => MapEntry(
          'images',
          MultipartFile.fromFileSync(
            i.path,
            filename: i.path.split(Platform.pathSeparator).last,
          ),
        ),
      ),
    );
    final _result = await _dio.fetch<List<dynamic>>(
      _setStreamType<List<StoreImageResponse>>(
        Options(
              method: 'PUT',
              headers: _headers,
              extra: _extra,
              contentType: 'multipart/form-data',
            )
            .compose(
              _dio.options,
              '/api/boss/store/images',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
      ),
    );
    final value = _result.data!
        .map(
          (dynamic i) => StoreImageResponse.fromJson(i as Map<String, dynamic>),
        )
        .toList();
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
