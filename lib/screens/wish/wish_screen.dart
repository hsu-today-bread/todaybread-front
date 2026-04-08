import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/keyword/keyword_provider.dart';
import 'package:todaybread/providers/store/favourite_store_provider.dart';

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
      context.read<KeywordProvider>().loadKeywords();
      context.read<FavouriteStoreProvider>().loadStores();
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keywordProvider = context.watch<KeywordProvider>();
    final storeProvider = context.watch<FavouriteStoreProvider>();

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
                        hintStyle:
                            const TextStyle(color: Color(0xFFBBBBBB)),
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
                      onPressed: keywordProvider.isLoading
                          ? null
                          : () => _addKeyword(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBackground,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('키워드 추가'),
                    ),
                  ),
                ],
              ),
              if (keywordProvider.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  keywordProvider.errorMessage!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFD64545),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              if (keywordProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: keywordProvider.keywords.map((keyword) {
                    return Chip(
                      label: Text(keyword.displayText),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      deleteIcon: const Icon(Icons.cancel, size: 18),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 0,
                      ),
                      onDeleted: () async {
                        try {
                          await context
                              .read<KeywordProvider>()
                              .removeKeyword(keyword.userKeywordId);
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.read<KeywordProvider>().errorMessage ??
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
              if (storeProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (storeProvider.stores.isEmpty)
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
                  children: storeProvider.stores.map((store) {
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
                                  child: store.imageUrl != null
                                      ? Image.network(
                                          store.imageUrl!,
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
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
                              onPressed: () {
                                context
                                    .read<FavouriteStoreProvider>()
                                    .toggleStore(store.storeId);
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

  Future<void> _addKeyword(BuildContext context) async {
    final text = _keywordController.text.trim();
    if (text.isEmpty) return;

    try {
      await context.read<KeywordProvider>().addKeyword(text);
      _keywordController.clear();
    } catch (_) {
      // errorMessage는 provider에서 이미 세팅되므로 UI가 자동으로 표시함
    }
  }
}
