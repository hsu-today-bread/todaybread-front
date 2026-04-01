import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/bread/bread_provider.dart';
import 'package:todaybread/screens/boss/boss_bread_create_screen.dart';
import 'package:todaybread/services/network/dio_client.dart';
import 'package:todaybread/utils/app_colors.dart';

/// 사장님 메뉴관리 메인 화면입니다.
///
/// 등록된 메뉴 목록을 보여주고, 비어 있으면 empty 상태와
/// 메뉴 등록 진입 버튼을 노출합니다.
class BossBreadManagementScreen extends StatefulWidget {
  const BossBreadManagementScreen({super.key});

  @override
  State<BossBreadManagementScreen> createState() =>
      _BossBreadManagementScreenState();
}

class _BossBreadManagementScreenState extends State<BossBreadManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BreadProvider>().fetchMyBreads();
    });
  }

  @override
  Widget build(BuildContext context) {
    final breadProvider = context.watch<BreadProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (breadProvider.isLoading && !breadProvider.hasFetched) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (breadProvider.hasBread) {
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              itemCount: breadProvider.breads.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final bread = breadProvider.breads[index];
                                return Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE4E4E4),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              bread.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '원가 ${bread.originalPrice}원',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF6E6E6E),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '할인가 ${bread.salePrice}원',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF6E6E6E),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '수량 ${bread.remainingQuantity}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF6E6E6E),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      _BreadThumbnail(imageUrl: bread.imageUrl),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const BossBreadCreateScreen(),
                                  ),
                                );
                                if (!context.mounted) {
                                  return;
                                }
                                context.read<BreadProvider>().fetchMyBreads();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBackground,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                '메뉴 등록하기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        const Spacer(),
                        SizedBox(
                          width: 210,
                          height: 210,
                          child: Lottie.asset('assets/lottie/emptyCart.json'),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '등록된 메뉴가 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BossBreadCreateScreen(),
                                ),
                              );
                              if (!context.mounted) {
                                return;
                              }
                              context.read<BreadProvider>().fetchMyBreads();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBackground,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '메뉴 등록하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF4A3A3A),
                size: 26,
              ),
            ),
          ),
          const Center(
            child: Text(
              '메뉴관리',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreadThumbnail extends StatelessWidget {
  final String? imageUrl;

  const _BreadThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveImageUrl(imageUrl);

    if (resolvedUrl == null) {
      return _buildFallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        resolvedUrl,
        width: 78,
        height: 78,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallback(),
      ),
    );
  }

  String? _resolveImageUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return '${DioClient.baseUrl}$value';
  }

  Widget _buildFallback() {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFF9B9B9B),
        size: 28,
      ),
    );
  }
}
