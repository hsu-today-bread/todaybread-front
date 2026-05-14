import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/models/review/boss_review_response.dart';
import 'package:todaybread/providers/boss/boss_review_provider.dart';
import 'package:todaybread/widgets/app_network_image.dart';

class BossReviewManagementScreen extends StatefulWidget {
  const BossReviewManagementScreen({super.key});

  @override
  State<BossReviewManagementScreen> createState() =>
      _BossReviewManagementScreenState();
}

class _BossReviewManagementScreenState
    extends State<BossReviewManagementScreen> {
  _ReviewSort _selectedSort = _ReviewSort.latest;
  _ReviewFilter _selectedFilter = _ReviewFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReviews();
    });
  }

  Future<void> _fetchReviews({bool reset = true}) async {
    await context.read<BossReviewProvider>().fetchReviews(
      sort: _selectedSort.queryValue,
      filter: _selectedFilter.queryValue,
      reset: reset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BossReviewProvider>();
    final reviews = provider.reviews;
    final summaryText = provider.hasFetched
        ? '총 ${provider.totalElements}개의 고객 리뷰'
        : '고객 리뷰를 불러오고 있습니다';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF7F7F7),
        surfaceTintColor: const Color(0xFFF7F7F7),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
        ),
        centerTitle: true,
        title: const Text(
          '리뷰관리',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _fetchReviews,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        summaryText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                    ),
                    PopupMenuButton<_ReviewSort>(
                      onSelected: _handleSortSelected,
                      color: Colors.white,
                      itemBuilder: (context) => _ReviewSort.values
                          .map(
                            (sort) => PopupMenuItem(
                              value: sort,
                              child: Text(sort.label),
                            ),
                          )
                          .toList(),
                      child: _ReviewOptionButton(
                        icon: Icons.tune_rounded,
                        label: _selectedSort.label,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final filter in _ReviewFilter.values) ...[
                        _ReviewFilterChip(
                          label: filter.label,
                          selected: filter == _selectedFilter,
                          onTap: () => _handleFilterSelected(filter),
                        ),
                        if (filter != _ReviewFilter.values.last)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (provider.isLoading && reviews.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                if (provider.isLoading && reviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.errorMessage != null && reviews.isEmpty)
                  _ReviewMessageState(
                    message: provider.errorMessage!,
                    actionLabel: '다시 불러오기',
                    onAction: _fetchReviews,
                  )
                else if (reviews.isEmpty)
                  const _ReviewMessageState(message: '등록된 리뷰가 없습니다.')
                else ...[
                  if (provider.errorMessage != null)
                    _InlineErrorMessage(message: provider.errorMessage!),
                  for (final review in reviews) ...[
                    _ReviewCard(review: review),
                    const SizedBox(height: 14),
                  ],
                  if (!provider.isLastPage)
                    Center(
                      child: TextButton(
                        onPressed: provider.isLoadingMore
                            ? null
                            : () => _fetchReviews(reset: false),
                        child: Text(
                          provider.isLoadingMore ? '불러오는 중...' : '리뷰 더보기',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSortSelected(_ReviewSort value) {
    if (_selectedSort == value) {
      return;
    }
    setState(() {
      _selectedSort = value;
    });
    _fetchReviews();
  }

  void _handleFilterSelected(_ReviewFilter value) {
    if (_selectedFilter == value) {
      return;
    }
    setState(() {
      _selectedFilter = value;
    });
    _fetchReviews();
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final BossReviewResponse review;

  @override
  Widget build(BuildContext context) {
    final reviewImageUrls = _reviewImageUrls(review);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.nickname,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              _StarRating(rating: review.rating),
              const SizedBox(width: 6),
              Text(
                review.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5E5E5E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(text: '리뷰 번호 ${review.reviewId}번'),
              if (review.createdAt.isNotEmpty)
                _InfoPill(text: _formatCreatedAt(review.createdAt)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.content.isEmpty ? '작성된 리뷰 내용이 없습니다.' : review.content,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.6,
              color: Colors.black,
            ),
          ),
          if (reviewImageUrls.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: reviewImageUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return _ReviewImage(url: reviewImageUrls[index]);
                },
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Text(
            '주문 메뉴',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: Text(
                  _menuText(review),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3A3A3A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewImage extends StatelessWidget {
  const _ReviewImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AppNetworkImage(
        imageUrl: url,
        width: 132,
        height: 132,
        fit: BoxFit.cover,
        placeholder: const _ImageErrorBox(),
      ),
    );
  }
}

class _ImageErrorBox extends StatelessWidget {
  const _ImageErrorBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      color: const Color(0xFFF2F2F2),
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        size: 30,
        color: Color(0xFF9A9A9A),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int index = 1; index <= 5; index++)
          Icon(
            rating >= index
                ? Icons.star_rounded
                : rating >= index - 0.5
                ? Icons.star_half_rounded
                : Icons.star_border_rounded,
            size: 18,
            color: const Color(0xFFFFC107),
          ),
      ],
    );
  }
}

class _ReviewOptionButton extends StatelessWidget {
  const _ReviewOptionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF555555)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF303030),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: Color(0xFF555555),
          ),
        ],
      ),
    );
  }
}

class _ReviewFilterChip extends StatelessWidget {
  const _ReviewFilterChip({
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
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.black : const Color(0xFFE2E2E2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : const Color(0xFF4A4A4A),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6D6D6D),
        ),
      ),
    );
  }
}

class _InlineErrorMessage extends StatelessWidget {
  const _InlineErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE05243),
        ),
      ),
    );
  }
}

class _ReviewMessageState extends StatelessWidget {
  const _ReviewMessageState({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6D6D6D),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _ReviewSort { latest, oldest, ratingHigh, ratingLow }

extension on _ReviewSort {
  String get label {
    switch (this) {
      case _ReviewSort.latest:
        return '최신순';
      case _ReviewSort.oldest:
        return '오래된순';
      case _ReviewSort.ratingHigh:
        return '별점 높은순';
      case _ReviewSort.ratingLow:
        return '별점 낮은순';
    }
  }

  String get queryValue {
    switch (this) {
      case _ReviewSort.latest:
        return 'LATEST';
      case _ReviewSort.oldest:
        return 'OLDEST';
      case _ReviewSort.ratingHigh:
        return 'RATING_HIGH';
      case _ReviewSort.ratingLow:
        return 'RATING_LOW';
    }
  }
}

enum _ReviewFilter { all, withImage, textOnly }

extension on _ReviewFilter {
  String get label {
    switch (this) {
      case _ReviewFilter.all:
        return '전체';
      case _ReviewFilter.withImage:
        return '사진 리뷰';
      case _ReviewFilter.textOnly:
        return '텍스트 리뷰';
    }
  }

  String get queryValue {
    switch (this) {
      case _ReviewFilter.all:
        return 'ALL';
      case _ReviewFilter.withImage:
        return 'WITH_IMAGE';
      case _ReviewFilter.textOnly:
        return 'TEXT_ONLY';
    }
  }
}

List<String> _reviewImageUrls(BossReviewResponse review) {
  return review.imageUrls.where((value) => value.isNotEmpty).toList();
}

String _menuText(BossReviewResponse review) {
  final breadName = review.breadName.isEmpty ? '메뉴명 없음' : review.breadName;
  if (review.purchaseCount <= 0) {
    return breadName;
  }
  return '$breadName · ${review.purchaseCount}번째 구매';
}

String _formatCreatedAt(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }
  return '${parsed.year}.${parsed.month.toString().padLeft(2, '0')}.'
      '${parsed.day.toString().padLeft(2, '0')}';
}
