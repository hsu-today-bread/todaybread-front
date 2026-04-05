import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:todaybread/models/keyword/keyword_create_request.dart';
import 'package:todaybread/models/keyword/keyword_create_response.dart';
import 'package:todaybread/models/keyword/keyword_delete_response.dart';
import 'package:todaybread/models/keyword/keyword_response.dart';

part 'keyword_api.g.dart';

@RestApi()
abstract class KeywordApi {
  factory KeywordApi(Dio dio, {String baseUrl}) = _KeywordApi;

  @GET('/api/keywords')
  Future<List<KeywordResponse>> getKeywords();

  @POST('/api/keywords')
  Future<KeywordCreateResponse> addKeyword(@Body() KeywordCreateRequest request);

  @DELETE('/api/keywords/{userKeywordId}')
  Future<KeywordDeleteResponse> deleteKeyword(
    @Path('userKeywordId') int userKeywordId,
  );
}
