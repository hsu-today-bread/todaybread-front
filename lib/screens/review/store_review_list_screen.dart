import 'package:flutter/material.dart';
import 'package:todaybread/models/review/store_review_response.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/review/review_service.dart';
import 'package:todaybread/utils/app_assets.dart';
import 'package:todaybread/utils/app_colors.dart';
import 'package:todaybread/widgets/app_network_image.dart';

class StoreReviewListScreen extends StatefulWidget {
  const StoreReviewListScreen({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  final int storeId;
  final String storeName;

  @override
  State<StoreReviewListScreen> createState() => _StoreReviewListScreenState();
}

class _StoreReviewListScreenState extends State<StoreReviewListScreen> {
  final List<StoreReviewResponse> _reviews = [];
  String _sort = 'LATEST';
  int _page = 0;
  int _totalElements = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _last = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _page = 0;
      _last = true;
      _reviews.clear();
    });

    try {
      final response = await ReviewService.instance.getStoreReviews(
        storeId: widget.storeId,
        sort: _sort,
        page: 0,
        size: 20,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _reviews.addAll(response.content);
        _totalElements = response.totalElements;
        _last = response.last;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = ApiException.messageFrom(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _last) {
      return;
    }

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _page + 1;
      final response = await ReviewService.instance.getStoreReviews(
        storeId: widget.storeId,
        sort: _sort,
        page: nextPage,
        size: 20,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _page = nextPage;
        _reviews.addAll(response.content);
        _totalElements = response.totalElements;
        _last = response.last;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoadingMore = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(ApiException.messageFrom(e))));
    }
  }

  void _changeSort(String value) {
    if (_sort == value) {
      return;
    }
    setState(() => _sort = value);
    _loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
        ),
        title: const Text(
          '모든 리뷰',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.storeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF171717),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '리뷰 $_totalElements개',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _SortChip(
                        label: '최신순',
                        selected: _sort == 'LATEST',
                        onTap: () => _changeSort('LATEST'),
                      ),
                      const SizedBox(width: 8),
                      _SortChip(
                        label: '별점 높은순',
                        selected: _sort == 'RATING_HIGH',
                        onTap: () => _changeSort('RATING_HIGH'),
                      ),
                      const SizedBox(width: 8),
                      _SortChip(
                        label: '별점 낮은순',
                        selected: _sort == 'RATING_LOW',
                        onTap: () => _changeSort('RATING_LOW'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF686868),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _loadFirstPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBackground,
                  foregroundColor: AppColors.onPrimaryBackground,
                  elevation: 0,
                ),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_reviews.isEmpty) {
      return const Center(
        child: Text(
          '아직 등록된 리뷰가 없습니다.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF8A8A8A),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
      itemCount: _reviews.length + (_last ? 0 : 1),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= _reviews.length) {
          return SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _isLoadingMore ? null : _loadMore,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBackground,
                side: const BorderSide(color: AppColors.primaryBackground),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoadingMore
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      '더 보기',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          );
        }

        return _ReviewListCard(review: _reviews[index]);
      },
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBackground : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.primaryBackground
                : const Color(0xFFE2E2E2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : const Color(0xFF686868),
          ),
        ),
      ),
    );
  }
}

class _ReviewListCard extends StatelessWidget {
  const _ReviewListCard({required this.review});

  final StoreReviewResponse review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E2DB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x122D2118),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: AppNetworkImage(
                    imageUrl: review.breadImageUrl,
                    fit: BoxFit.cover,
                    placeholder: Image.asset(
                      AppAssets.breadImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.breadName.isEmpty ? '구매한 메뉴' : review.breadName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF171717),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      review.nickname,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF878787),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '⭐ ${review.rating.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF5A4300),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            review.content.isEmpty ? '작성된 리뷰 내용이 없습니다.' : review.content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B3B3B),
            ),
          ),
          if (review.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.imageUrls.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 76,
                      height: 76,
                      child: AppNetworkImage(
                        imageUrl: review.imageUrls[index],
                        fit: BoxFit.cover,
                        placeholder: Container(color: const Color(0xFFF1EFEA)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
