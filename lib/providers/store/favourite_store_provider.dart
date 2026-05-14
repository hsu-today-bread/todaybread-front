import 'package:flutter/material.dart';
import 'package:todaybread/models/store/favourite_store_response.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/store/store_service.dart';

class FavouriteStoreProvider extends ChangeNotifier {
  final StoreService _service = StoreService.instance;

  List<FavouriteStoreResponse> stores = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadStores() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      stores = await _service.getFavouriteStores();
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleStore(int storeId) async {
    final prev = List<FavouriteStoreResponse>.from(stores);
    stores = stores.where((s) => s.storeId != storeId).toList();
    notifyListeners();

    try {
      await _service.toggleFavouriteStore(storeId);
    } catch (e) {
      stores = prev;
      errorMessage = ApiException.messageFrom(e);
      notifyListeners();
    }
  }
}
