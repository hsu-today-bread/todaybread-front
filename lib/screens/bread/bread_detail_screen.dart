import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/bread/bread_detail_provider.dart';
import 'package:todaybread/screens/order/purchase_screen.dart';
import 'package:todaybread/screens/store/store_detail_screen.dart';
import 'package:todaybread/utils/app_assets.dart';
import 'package:todaybread/utils/app_colors.dart';
import 'package:todaybread/utils/display_helper.dart';

class BreadDetailScreen extends StatelessWidget {
  const BreadDetailScreen({
    super.key,
    required this.breadId,
    required this.storeId,
  });

  final int breadId;
  final int storeId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          BreadDetailProvider(breadId: breadId, storeId: storeId)..fetch(),
      child: const _BreadDetailView(),
    );
  }
}

class _BreadDetailView extends StatelessWidget {
  const _BreadDetailView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BreadDetailProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar:
          provider.breadDetail == null || provider.storeDetail == null
          ? null
          : _BottomActionBar(provider: provider),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && !provider.hasFetched) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.breadDetail == null || provider.storeDetail == null) {
            return _ErrorState(
              message: provider.errorMessage ?? '메뉴 상세를 불러오지 못했습니다.',
              onRetry: provider.fetch,
            );
          }

          final bread = provider.breadDetail!;
          final store = provider.store!;
          final breadImageUrl = DisplayHelper.resolveImageUrl(bread.imageUrl);
          final storeLogoUrl = DisplayHelper.resolveImageUrl(
            provider.storeImages.isEmpty
                ? null
                : provider.storeImages.first.imageUrl,
          );
          final remainingTimeText = provider.remainingTimeText;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 332,
                      child: breadImageUrl == null
                          ? Image.asset(AppAssets.breadImage, fit: BoxFit.cover)
                          : Image.network(
                              breadImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  AppAssets.breadImage,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CircleOverlayButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  StoreDetailScreen(storeId: store.id),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Color(0xFF3E342B)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          '매장 보러가기',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${store.name} ${bread.name}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.22,
                          color: Color(0xFF151515),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              width: 58,
                              height: 58,
                              color: const Color(0xFFF3EFE9),
                              child: storeLogoUrl == null
                                  ? Image.asset(
                                      AppAssets.splashLogo,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      storeLogoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Image.asset(
                                              AppAssets.splashLogo,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    provider.fullAddress,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 1.45,
                                      color: Color(0xFF4C4C4C),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF4D6),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    '⭐ 4.8',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF5A4300),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (bread.remainingQuantity > 0)
                        Text(
                          '주문 종료까지 남은 시간 : $remainingTimeText',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE0462E),
                          ),
                        ),
                      const SizedBox(height: 26),
                      _SectionTitle(title: '메뉴명'),
                      const SizedBox(height: 10),
                      Text(
                        bread.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF202020),
                        ),
                      ),
                      const SizedBox(height: 26),
                      _SectionTitle(title: '상세 설명'),
                      const SizedBox(height: 10),
                      Text(
                        bread.description.isEmpty
                            ? '등록된 상세 설명이 없습니다.'
                            : bread.description,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4F1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          '구매 후 최대한 빨리 섭취해주세요.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B3B31),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const _SectionTitle(title: '수량'),
                          Text(
                            '잔여 ${bread.remainingQuantity}개',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8D8D8D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _QuantityButton(
                            label: '-',
                            onTap: provider.canOrder
                                ? provider.decreaseQuantity
                                : null,
                          ),
                          Container(
                            width: 72,
                            height: 52,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFD9D9D9),
                              ),
                            ),
                            child: Text(
                              '${provider.quantity}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          _QuantityButton(
                            label: '+',
                            onTap: provider.canOrder
                                ? provider.increaseQuantity
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.provider});

  final BreadDetailProvider provider;

  @override
  Widget build(BuildContext context) {
    final enabled = provider.canOrder && provider.quantity > 0;
    final bread = provider.breadDetail;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: enabled && !provider.isAddingToCart
                    ? () async {
                        final success = await provider.addToCart();
                        if (!context.mounted) return;
                        if (success) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('장바구니에 담았습니다.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                provider.errorMessage ?? '장바구니 담기에 실패했습니다.',
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  foregroundColor: AppColors.primaryBackground,
                  side: BorderSide(
                    color: enabled
                        ? AppColors.primaryBackground
                        : const Color(0xFFD6D6D6),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: provider.isAddingToCart
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryBackground,
                        ),
                      )
                    : const Text(
                        '장바구니에 담기',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: enabled
                    ? () async {
                        if (bread == null) {
                          return;
                        }
                        await showDirectPurchaseNoticeAndOpenScreen(
                          context,
                          items: [
                            PurchaseItem(
                              name: bread.name,
                              unitPrice: bread.salePrice,
                              quantity: provider.quantity,
                            ),
                          ],
                          breadId: bread.id,
                          quantity: provider.quantity,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: AppColors.primaryBackground,
                  disabledBackgroundColor: const Color(0xFFD6D6D6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '바로 구매',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
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

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: onTap == null
              ? const Color(0xFFCFD9D6)
              : AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: onTap == null ? const Color(0xFFF4F4F4) : Colors.white,
            ),
          ),
        ),
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
