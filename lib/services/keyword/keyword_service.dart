import 'package:todaybread/models/keyword/keyword_create_request.dart';
import 'package:todaybread/models/keyword/keyword_create_response.dart';
import 'package:todaybread/models/keyword/keyword_delete_response.dart';
import 'package:todaybread/models/keyword/keyword_response.dart';
import 'package:todaybread/services/keyword/keyword_api.dart';
import 'package:todaybread/services/network/dio_client.dart';

class KeywordService {
  KeywordService._();

  static final KeywordService instance = KeywordService._();

  final KeywordApi _api = KeywordApi(DioClient.instance);

  Future<List<KeywordResponse>> getKeywords() async {
    return await _api.getKeywords();
  }

  Future<KeywordCreateResponse> addKeyword(String keyword) async {
    return await _api.addKeyword(KeywordCreateRequest(keyword: keyword));
  }

  Future<KeywordDeleteResponse> deleteKeyword(int userKeywordId) async {
    return await _api.deleteKeyword(userKeywordId);
  }
}
