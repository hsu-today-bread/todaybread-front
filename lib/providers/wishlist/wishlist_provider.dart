import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:todaybread/models/interest_area/interest_area_response.dart';
import 'package:todaybread/models/keyword/keyword_response.dart';
import 'package:todaybread/models/store/favourite_store_response.dart';
import 'package:todaybread/services/interest_area/interest_area_service.dart';
import 'package:todaybread/services/keyword/keyword_service.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/store/store_service.dart';
import 'package:todaybread/services/wishlist/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _wishlistService = WishlistService.instance;
  final KeywordService _keywordService = KeywordService.instance;
  final InterestAreaService _interestAreaService = InterestAreaService.instance;
  final StoreService _storeService = StoreService.instance;

  List<KeywordResponse> keywords = [];
  List<FavouriteStoreResponse> favouriteStores = [];
  InterestAreaResponse? interestArea;
  bool isLoading = false;
  bool isInterestAreaLoading = false;
  String? errorMessage;
  String? interestAreaErrorMessage;

  bool get hasInterestArea => interestArea != null;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    interestAreaErrorMessage = null;
    notifyListeners();

    try {
      final result = await _wishlistService.getWishlist();
      keywords = result.keywords;
      favouriteStores = result.favouriteStores;
      await loadInterestArea(silent: true);
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInterestArea({bool silent = false}) async {
    if (!silent) {
      isInterestAreaLoading = true;
      interestAreaErrorMessage = null;
      notifyListeners();
    }

    try {
      interestArea = await _interestAreaService.getInterestArea();
      interestAreaErrorMessage = null;
    } catch (e) {
      interestAreaErrorMessage = ApiException.messageFrom(e);
    } finally {
      if (!silent) {
        isInterestAreaLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> ensureCanAddKeyword() async {
    await loadInterestArea();
    return interestArea != null;
  }

  Future<void> saveInterestArea({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    isInterestAreaLoading = true;
    interestAreaErrorMessage = null;
    notifyListeners();

    final request = InterestAreaRequest(
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );

    try {
      interestArea = interestArea == null
          ? await _interestAreaService.createInterestArea(request)
          : await _interestAreaService.updateInterestArea(request);
    } catch (e) {
      interestAreaErrorMessage = ApiException.messageFrom(e);
      rethrow;
    } finally {
      isInterestAreaLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteInterestArea() async {
    final previous = interestArea;
    interestArea = null;
    notifyListeners();

    try {
      await _interestAreaService.deleteInterestArea();
      return true;
    } catch (e) {
      interestArea = previous;
      interestAreaErrorMessage = ApiException.messageFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> addKeyword(String keyword) async {
    try {
      await _keywordService.addKeyword(keyword);
      await load();
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      if (_isInterestAreaRequired(e)) {
        interestArea = null;
        interestAreaErrorMessage = errorMessage;
      }
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

  bool _isInterestAreaRequired(Object error) {
    final apiException = _apiExceptionFrom(error);
    return apiException?.code == 'INTEREST_AREA_003' ||
        apiException?.code == 'INTEREST_AREA_REQUIRED';
  }

  ApiException? _apiExceptionFrom(Object error) {
    if (error is ApiException) {
      return error;
    }
    if (error is DioException) {
      final inner = error.error;
      if (inner is ApiException) {
        return inner;
      }
      return ApiException.fromDio(error);
    }
    return null;
  }
}
