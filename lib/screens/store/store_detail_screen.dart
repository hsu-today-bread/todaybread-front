import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/models/bread/bread_common_response.dart';
import 'package:todaybread/models/review/store_review_response.dart';
import 'package:todaybread/models/store/store_detail_response.dart';
import 'package:todaybread/providers/store/store_detail_provider.dart';
import 'package:todaybread/screens/bread/bread_detail_screen.dart';
import 'package:todaybread/utils/app_assets.dart';
import 'package:todaybread/utils/app_colors.dart';
import 'package:todaybread/utils/display_helper.dart';
import 'package:todaybread/widgets/app_network_image.dart';
import 'package:todaybread/widgets/bread_list_card.dart';

class StoreDetailScreen extends StatelessWidget {
  const StoreDetailScreen({super.key, required this.storeId});

  final int storeId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoreDetailProvider(storeId: storeId)..fetch(),
      child: const _StoreDetailView(),
    );
  }
}

class _StoreDetailView extends StatelessWidget {
  const _StoreDetailView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreDetailProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Builder(
        builder: (context) {
          if (provider.isLoading && !provider.hasFetched) {
            return Stack(
              children: [
                const Center(child: CircularProgressIndicator()),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _CircleOverlayButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            );
          }

          if (provider.store == null) {
            return Stack(
              children: [
                _ErrorState(
                  message: provider.errorMessage ?? '매장 상세를 불러오지 못했습니다.',
                  onRetry: provider.fetch,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _CircleOverlayButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            );
          }

          final store = provider.store!;
          final imageUrls = provider.storeImages
              .map((value) => value.imageUrl)
              .where((value) => value.isNotEmpty)
              .toList();

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 332,
                          child: PageView.builder(
                            itemCount: imageUrls.isEmpty ? 1 : imageUrls.length,
                            onPageChanged: provider.setCurrentImageIndex,
                            itemBuilder: (context, index) {
                              if (imageUrls.isEmpty) {
                                return Image.asset(
                                  AppAssets.breadImage,
                                  fit: BoxFit.cover,
                                );
                              }

                              return AppNetworkImage(
                                imageUrl: imageUrls[index],
                                fit: BoxFit.cover,
                                placeholder: Image.asset(
                                  AppAssets.breadImage,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                        if (imageUrls.length > 1)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 18,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(imageUrls.length, (
                                index,
                              ) {
                                final isActive =
                                    provider.currentImageIndex == index;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: isActive ? 20 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: const TextStyle(
                              fontSize: 29,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              color: Color(0xFF151515),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      store.addressLine1,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        height: 1.45,
                                        color: Color(0xFF656565),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      store.addressLine2.trim().isEmpty
                                          ? '상세 주소 정보 없음'
                                          : store.addressLine2,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        height: 1.45,
                                        color: Color(0xFF656565),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              _FavouriteButton(
                                isFavourite: provider.isFavourite,
                                isLoading: provider.isTogglingFavourite,
                                onTap: () async {
                                  final message = await provider
                                      .toggleFavourite();
                                  if (message != null && context.mounted) {
                                    _showTodoSnackBar(context, message);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF4D6),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '⭐ ${DisplayHelper.formatRating(provider.storeDetail?.averageRating ?? 0, provider.storeDetail?.reviewCount ?? 0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF5A4300),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _SellingStatusChip(
                                status: provider.sellingStatus,
                                label: provider.sellingStatusLabel,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  provider.orderStatusText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: provider.canOrder
                                        ? const Color(0xFFE0462E)
                                        : const Color(0xFF7A6A5A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          if (provider.reviews.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F3EE),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Text(
                                '아직 등록된 리뷰가 없습니다.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6D6256),
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              height: 176,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: provider.reviews.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final review = provider.reviews[index];
                                  return _ReviewCard(review: review);
                                },
                              ),
                            ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showTodoSnackBar(
                                context,
                                '전체 리뷰 화면 연결 예정입니다.',
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: AppColors.primaryBackground,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '모든 리뷰 보기',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const _SectionTitle(title: '메뉴'),
                          const SizedBox(height: 14),
                          if (provider.breads.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F3EE),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Text(
                                '등록된 메뉴가 없습니다.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6D6256),
                                ),
                              ),
                            )
                          else
                            ...provider.breads.map(
                              (bread) =>
                                  _buildBreadCard(context, provider, bread),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // 스크롤과 무관하게 항상 상단에 고정되는 뒤로가기 버튼
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: _CircleOverlayButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBreadCard(
    BuildContext context,
    StoreDetailProvider provider,
    BreadCommonResponse bread,
  ) {
    return BreadListCard(
      name: bread.name,
      imageUrl: bread.imageUrl,
      distanceText: provider.distanceText,
      salePrice: bread.salePrice,
      originalPrice: bread.originalPrice,
      remainingTimeText: provider.remainingTimeText,
      isSoldOut: !provider.canOrder || bread.remainingQuantity <= 0,
      ratingText: DisplayHelper.formatRating(
        provider.storeDetail?.averageRating ?? 0,
        provider.storeDetail?.reviewCount ?? 0,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                BreadDetailScreen(breadId: bread.id, storeId: bread.storeId),
          ),
        );
      },
    );
  }
}

class _SellingStatusChip extends StatelessWidget {
  const _SellingStatusChip({required this.status, required this.label});

  final StoreSellingStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final style = switch (status) {
      StoreSellingStatus.selling => (
        background: const Color(0xFFE9F7F4),
        foreground: const Color(0xFF21796F),
        icon: Icons.local_fire_department_rounded,
      ),
      StoreSellingStatus.openSoldOut => (
        background: const Color(0xFFFFF0E8),
        foreground: const Color(0xFFD95A2B),
        icon: Icons.inventory_2_rounded,
      ),
      StoreSellingStatus.closed => (
        background: const Color(0xFFF1EEE9),
        foreground: const Color(0xFF74675A),
        icon: Icons.lock_clock_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: style.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavouriteButton extends StatelessWidget {
  const _FavouriteButton({
    required this.isFavourite,
    required this.isLoading,
    required this.onTap,
  });

  final bool isFavourite;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isFavourite ? const Color(0xFFFFF1F0) : const Color(0xFFF7F3EE),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isFavourite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavourite
                        ? const Color(0xFFE0465D)
                        : const Color(0xFF6B6259),
                    size: 26,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final StoreReviewResponse review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E2DB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x122D2118),
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
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F3EE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF8B7B68),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.nickname,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '⭐ ${review.rating.toStringAsFixed(1)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5A4300),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: Color(0xFF525252),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF161616),
      ),
    );
  }
}

class _CircleOverlayButton extends StatelessWidget {
  const _CircleOverlayButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 20, color: Colors.black),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBackground,
                  foregroundColor: Colors.white,
                ),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showTodoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
