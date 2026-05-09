import 'package:flutter/material.dart';
import 'package:todaybread/models/review/boss_review_response.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/review/review_service.dart';

class BossReviewProvider extends ChangeNotifier {
  final ReviewService _service = ReviewService.instance;

  static const int pageSize = 20;

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasFetched = false;
  bool isLastPage = true;
  int currentPage = 0;
  int totalElements = 0;
  String? errorMessage;
  List<BossReviewResponse> reviews = [];
  String _currentSort = 'LATEST';
  String _currentFilter = 'ALL';

  Future<List<BossReviewResponse>?> refresh({
    String sort = 'LATEST',
    String filter = 'ALL',
  }) {
    return fetchReviews(sort: sort, filter: filter, reset: true);
  }

  Future<List<BossReviewResponse>?> fetchReviews({
    String? sort,
    String? filter,
    bool reset = true,
  }) async {
    final nextSort = sort ?? _currentSort;
    final nextFilter = filter ?? _currentFilter;
    final nextPage = reset ? 0 : currentPage + 1;
    final criteriaChanged =
        reset && (nextSort != _currentSort || nextFilter != _currentFilter);

    if (reset) {
      _currentSort = nextSort;
      _currentFilter = nextFilter;
    } else if (isLoading || isLoadingMore || isLastPage) {
      return reviews;
    }

    try {
      if (reset) {
        isLoading = true;
        if (criteriaChanged) {
          reviews = [];
          currentPage = 0;
          totalElements = 0;
          isLastPage = true;
        }
      } else {
        isLoadingMore = true;
      }
      errorMessage = null;
      notifyListeners();

      final response = await _service.getBossReviews(
        sort: nextSort,
        filter: nextFilter,
        page: nextPage,
        size: pageSize,
      );
      reviews = reset ? response.content : [...reviews, ...response.content];
      currentPage = nextPage;
      totalElements = response.totalElements;
      isLastPage = response.last;
      hasFetched = true;
      return reviews;
    } catch (e) {
      errorMessage = ApiException.messageFrom(e);
      if (!hasFetched) {
        reviews = [];
      }
      hasFetched = true;
      return null;
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }
}
