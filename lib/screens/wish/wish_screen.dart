import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/keyword/keyword_provider.dart';

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
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KeywordProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
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
                      onPressed: provider.isLoading
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
              if (provider.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFD64545),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provider.keywords.map((keyword) {
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
            ],
          ),
        ),
      ),
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
