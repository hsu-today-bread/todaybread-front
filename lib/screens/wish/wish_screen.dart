import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/interest_area/interest_area_provider.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/providers/wishlist/wishlist_provider.dart';
import 'package:todaybread/screens/interest_area/interest_area_search_screen.dart';
import 'package:todaybread/utils/display_helper.dart';

class WishScreen extends StatefulWidget {
  const WishScreen({super.key});

  @override
  State<WishScreen> createState() => _WishScreenState();
}

class _WishScreenState extends State<WishScreen> {
  final TextEditingController _keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || context.read<AuthProvider>().role != UserRole.user) {
        return;
      }
      context.read<WishlistProvider>().load();
      context.read<InterestAreaProvider>().fetch();
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '키워드 관리',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _keywordController,
                      maxLength: 10,
                      decoration: InputDecoration(
                        hintText: '등록할 키워드를 입력해주세요',
                        hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBackground,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: ElevatedButton(
                      onPressed: wishlistProvider.isLoading
                          ? null
                          : () => _onAddKeywordTap(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBackground,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('키워드 추가'),
                    ),
                  ),
                ],
              ),
              if (wishlistProvider.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  wishlistProvider.errorMessage!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFD64545),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              if (wishlistProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: wishlistProvider.keywords.map((keyword) {
                    return Chip(
                      label: Text(keyword.displayText),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      deleteIcon: const Icon(Icons.cancel, size: 18),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 0,
                      ),
                      onDeleted: () async {
                        try {
                          await context.read<WishlistProvider>().removeKeyword(
                            keyword.userKeywordId,
                          );
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.read<WishlistProvider>().errorMessage ??
                                    '키워드 삭제에 실패했습니다.',
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 32),
              const Text(
                '단골 매장 관리',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                '하트 클릭 시 단골 매장이 해제됩니다.',
                style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 16),
              if (wishlistProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (wishlistProvider.favouriteStores.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      '단골 매장이 없습니다.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
                    ),
                  ),
                )
              else
                Column(
                  children: wishlistProvider.favouriteStores.map((store) {
                    final imageUrl = DisplayHelper.resolveImageUrl(
                      store.imageUrl,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                ClipOval(
                                  child: imageUrl != null
                                      ? Image.network(
                                          imageUrl,
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  _storePlaceholder(),
                                        )
                                      : _storePlaceholder(),
                                ),
                                if (!store.isSelling)
                                  ClipOval(
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      color: Colors.black54,
                                      alignment: Alignment.center,
                                      child: const Text(
                                        '영업\n종료',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    store.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    store.address,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                final storeName = store.name;
                                final success = await context
                                    .read<WishlistProvider>()
                                    .toggleStore(store.storeId);
                                if (!context.mounted || !success) {
                                  return;
                                }
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text('$storeName 단골 매장 해제'),
                                    ),
                                  );
                              },
                              icon: const Icon(
                                Icons.favorite,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _storePlaceholder() {
    return Container(
      width: 64,
      height: 64,
      color: const Color(0xFFEEEEEE),
      child: const Icon(Icons.store, color: Color(0xFFAAAAAA), size: 32),
    );
  }

  Future<void> _onAddKeywordTap(BuildContext context) async {
    final interestAreaProvider = context.read<InterestAreaProvider>();

    // 최신 관심지역 상태 확인
    await interestAreaProvider.fetch();

    if (!context.mounted) return;

    if (interestAreaProvider.interestArea == null) {
      _showInterestAreaRequiredSheet(context);
    } else {
      await _addKeyword(context);
    }
  }

  void _showInterestAreaRequiredSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '관심지역을 먼저 설정해주세요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '키워드 알림을 받으려면 관심지역 설정이 필요해요.\n설정한 지역 3km 안의 매장에서 올라오는 빵을 알려드릴게요.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => const InterestAreaSearchScreen(),
                      ),
                    );
                    if (!context.mounted) return;
                    if (result == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('관심지역이 설정됐어요.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBackground,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '관심지역 설정하기',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addKeyword(BuildContext context) async {
    final text = _keywordController.text.trim();
    if (text.isEmpty) return;

    try {
      await context.read<WishlistProvider>().addKeyword(text);
      _keywordController.clear();
    } catch (e) {
      if (!context.mounted) return;
      // INTEREST_AREA_REQUIRED 에러 예외 처리
      final provider = context.read<WishlistProvider>();
      if (provider.errorMessage != null) {
        // errorMessage는 provider에서 이미 세팅되어 UI가 자동으로 표시함
      }
    }
  }
}
