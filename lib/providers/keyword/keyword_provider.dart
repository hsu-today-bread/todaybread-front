import 'package:flutter/material.dart';
import 'package:todaybread/models/keyword/keyword_response.dart';
import 'package:todaybread/services/keyword/keyword_service.dart';
import 'package:todaybread/services/network/api_exception.dart';

class KeywordProvider extends ChangeNotifier {
  List<KeywordResponse> _keywords = [];
  bool isLoading = false;
  String? errorMessage;

  List<KeywordResponse> get keywords => _keywords;

  /// 서버에서 키워드 목록을 불러온다.
  Future<void> loadKeywords() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _keywords = await KeywordService.instance.getKeywords();
    } catch (e) {
      errorMessage = '키워드를 불러오지 못했습니다.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 키워드를 서버에 추가한다.
  ///
  /// 실패 시 서버에서 내려온 메시지를 [errorMessage]에 담아 반환한다.
  Future<void> addKeyword(String keyword) async {
    try {
      await KeywordService.instance.addKeyword(keyword);
      await loadKeywords();
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      notifyListeners();
      rethrow;
    }
  }

  /// 키워드를 서버에서 삭제한다.
  Future<void> removeKeyword(int userKeywordId) async {
    try {
      await KeywordService.instance.deleteKeyword(userKeywordId);
      _keywords.removeWhere((k) => k.userKeywordId == userKeywordId);
      notifyListeners();
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      notifyListeners();
      rethrow;
    }
  }
}
