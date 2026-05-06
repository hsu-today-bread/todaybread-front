import 'package:flutter/material.dart';
import 'package:todaybread/models/keyword/keyword_response.dart';
import 'package:todaybread/models/store/favourite_store_response.dart';
import 'package:todaybread/services/keyword/keyword_service.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/store/store_service.dart';
import 'package:todaybread/services/wishlist/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _wishlistService = WishlistService.instance;
  final KeywordService _keywordService = KeywordService.instance;
  final StoreService _storeService = StoreService.instance;

  List<KeywordResponse> keywords = [];
  List<FavouriteStoreResponse> favouriteStores = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _wishlistService.getWishlist();
      keywords = result.keywords;
      favouriteStores = result.favouriteStores;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addKeyword(String keyword) async {
    try {
      await _keywordService.addKeyword(keyword);
      await load();
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeKeyword(int userKeywordId) async {
    final prev = List<KeywordResponse>.from(keywords);
    keywords.removeWhere((k) => k.userKeywordId == userKeywordId);
    notifyListeners();

    try {
      await _keywordService.deleteKeyword(userKeywordId);
    } catch (e) {
      keywords = prev;
      errorMessage = ApiException.messageFrom(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> toggleStore(int storeId) async {
    final prev = List<FavouriteStoreResponse>.from(favouriteStores);
    favouriteStores.removeWhere((s) => s.storeId == storeId);
    notifyListeners();

    try {
      await _storeService.toggleFavouriteStore(storeId);
      return true;
    } catch (e) {
      favouriteStores = prev;
      errorMessage = ApiException.messageFrom(e);
      notifyListeners();
      return false;
    }
  }
}
