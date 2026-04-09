import 'dart:math' as math;

import 'package:flutter/material.dart';

class BossReviewManagementScreen extends StatefulWidget {
  const BossReviewManagementScreen({super.key});

  @override
  State<BossReviewManagementScreen> createState() =>
      _BossReviewManagementScreenState();
}

class _BossReviewManagementScreenState
    extends State<BossReviewManagementScreen> {
  _ReviewSort _selectedSort = _ReviewSort.latest;
  bool _showAll = false;

  List<_ReviewItem> get _sortedReviews {
    final reviews = List<_ReviewItem>.of(_dummyReviews);
    switch (_selectedSort) {
      case _ReviewSort.latest:
        reviews.sort((a, b) => b.reviewNumber.compareTo(a.reviewNumber));
        break;
      case _ReviewSort.ratingHigh:
        reviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case _ReviewSort.ratingLow:
        reviews.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
    return reviews;
  }

  int get _visibleReviewCount {
    if (_showAll) {
      return _sortedReviews.length;
    }
    return math.min(5, _sortedReviews.length);
  }

  double get _averageRating {
    if (_dummyReviews.isEmpty) {
      return 0;
    }
    final sum = _dummyReviews.fold<double>(
      0,
      (value, item) => value + item.rating,
    );
    return sum / _dummyReviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _sortedReviews;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '가게 평균 별점 :',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFC83D),
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '최근 한달간의 리뷰입니다',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                  ),
                  PopupMenuButton<_ReviewSort>(
                    onSelected: (value) {
                      setState(() {
                        _selectedSort = value;
                      });
                    },
                    color: Colors.white,
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _ReviewSort.latest,
                        child: Text('최신순'),
                      ),
                      PopupMenuItem(
                        value: _ReviewSort.ratingHigh,
                        child: Text('별점 높은 순'),
                      ),
                      PopupMenuItem(
                        value: _ReviewSort.ratingLow,
                        child: Text('별점 낮은 순'),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E2E2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            size: 18,
                            color: Color(0xFF555555),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedSort.label,
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              for (int index = 0; index < _visibleReviewCount; index++) ...[
                _ReviewCard(review: reviews[index]),
                const SizedBox(height: 14),
              ],
              if (!_showAll && reviews.length > 5)
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showAll = true;
                      });
                    },
                    child: const Text(
                      '리뷰 더보기',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final _ReviewItem review;

  @override
  Widget build(BuildContext context) {
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
          Text(
            review.nickname,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _StarRating(rating: review.rating),
          const SizedBox(height: 12),
          Text(
            '리뷰 번호 : ${review.reviewNumber}번',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6D6D6D),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            review.content,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.6,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/img_bread.png',
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
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
            children: review.orderedMenus
                .map(
                  (menu) => Container(
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
                      menu,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3A3A3A),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
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
      children: [
        for (int i = 1; i <= 5; i++)
          Icon(
            i <= rating.round()
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: const Color(0xFFFFC83D),
            size: 20,
          ),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF5E5E5E),
          ),
        ),
      ],
    );
  }
}

enum _ReviewSort { latest, ratingHigh, ratingLow }

extension on _ReviewSort {
  String get label {
    switch (this) {
      case _ReviewSort.latest:
        return '최신순';
      case _ReviewSort.ratingHigh:
        return '별점 높은 순';
      case _ReviewSort.ratingLow:
        return '별점 낮은 순';
    }
  }
}

class _ReviewItem {
  const _ReviewItem({
    required this.reviewNumber,
    required this.nickname,
    required this.rating,
    required this.content,
    required this.orderedMenus,
  });

  final int reviewNumber;
  final String nickname;
  final double rating;
  final String content;
  final List<String> orderedMenus;
}

// TODO: Replace dummy reviews with real review API response and server-side sorting.
const List<_ReviewItem> _dummyReviews = [
  _ReviewItem(
    reviewNumber: 108,
    nickname: '빵좋아',
    rating: 5.0,
    content: '포장도 깔끔하고 빵 상태가 좋아서 만족했어요. 다음에도 재주문할 것 같아요.',
    orderedMenus: ['소금빵', '우유식빵'],
  ),
  _ReviewItem(
    reviewNumber: 107,
    nickname: '한입만',
    rating: 4.5,
    content: '버터 향이 진하고 촉촉했어요. 할인 가격이라 더 좋았습니다.',
    orderedMenus: ['크루아상', '앙버터'],
  ),
  _ReviewItem(
    reviewNumber: 106,
    nickname: '오늘도빵',
    rating: 4.0,
    content: '전체적으로 괜찮았고 양도 충분했어요. 다만 조금 더 따뜻했으면 좋겠어요.',
    orderedMenus: ['단팥빵'],
  ),
  _ReviewItem(
    reviewNumber: 105,
    nickname: '리뷰왕',
    rating: 5.0,
    content: '직원분도 친절하고 픽업도 빨랐어요. 재방문 의사 있습니다.',
    orderedMenus: ['소보루빵', '꽈배기'],
  ),
  _ReviewItem(
    reviewNumber: 104,
    nickname: '버터러버',
    rating: 3.5,
    content: '맛은 있었는데 제가 기대한 식감이랑은 조금 달랐어요.',
    orderedMenus: ['버터프레첼'],
  ),
  _ReviewItem(
    reviewNumber: 103,
    nickname: '주말간식',
    rating: 4.5,
    content: '가성비 좋고 종류가 다양해서 좋았습니다. 가족들도 다 좋아했어요.',
    orderedMenus: ['치아바타', '베이글', '소금빵'],
  ),
  _ReviewItem(
    reviewNumber: 102,
    nickname: '빵순이',
    rating: 5.0,
    content: '포장 뜯자마자 향이 너무 좋아서 바로 먹었어요. 다음에도 꼭 주문할게요.',
    orderedMenus: ['우유식빵', '밤식빵'],
  ),
];
