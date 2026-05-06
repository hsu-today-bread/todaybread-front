import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/models/bread/bread_common_response.dart';
import 'package:todaybread/providers/bread/bread_provider.dart';
import 'package:todaybread/screens/boss/boss_bread_detail_screen.dart';
import 'package:todaybread/screens/boss/boss_bread_create_screen.dart';
import 'package:todaybread/services/network/dio_client.dart';
import 'package:todaybread/utils/app_colors.dart';

/// 사장님 메뉴관리 메인 화면입니다.
///
/// 등록된 메뉴 목록을 보여주고, 비어 있으면 empty 상태와
/// 메뉴 등록 진입 버튼을 노출합니다.
class BossBreadManagementScreen extends StatefulWidget {
  const BossBreadManagementScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

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
          padding: EdgeInsets.fromLTRB(20, widget.showAppBar ? 10 : 18, 20, 24),
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
                                return _BreadMenuCard(
                                  bread: bread,
                                  onTap: () => _openBreadDetail(bread),
                                  onToggleSoldOut: () =>
                                      _handleSoldOutToggle(bread),
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
          if (widget.showAppBar)
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

  Future<void> _openBreadDetail(BreadCommonResponse bread) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BossBreadDetailScreen(bread: bread)),
    );
    if (!mounted) {
      return;
    }
    context.read<BreadProvider>().fetchMyBreads();
  }

  Future<void> _handleSoldOutToggle(BreadCommonResponse bread) async {
    if (bread.remainingQuantity == 0) {
      await _showReleaseSoldOutDialog(bread);
      return;
    }
    await _showSoldOutConfirmDialog(bread);
  }

  Future<void> _showSoldOutConfirmDialog(BreadCommonResponse bread) async {
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _BreadActionDialog(
          title: '품절 처리하겠습니까?',
          onClose: () => Navigator.of(dialogContext).pop(false),
          child: Center(
            child: SizedBox(
              width: 140,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE7776B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (shouldProceed != true || !mounted) {
      return;
    }

    final success = await context.read<BreadProvider>().updateBreadStock(
      breadId: bread.id,
      remainingQuantity: 0,
    );
    if (!mounted) {
      return;
    }
    _showActionResultSnackBar(success: success, successMessage: '품절 처리되었습니다.');
  }

  Future<void> _showReleaseSoldOutDialog(BreadCommonResponse bread) async {
    final shouldProceed = await showDialog<int>(
      context: context,
      builder: (_) => const _StockInputDialog(title: '품절 해제'),
    );

    if (shouldProceed == null || !mounted) {
      return;
    }

    final success = await context.read<BreadProvider>().updateBreadStock(
      breadId: bread.id,
      remainingQuantity: shouldProceed,
    );
    if (!mounted) {
      return;
    }
    _showActionResultSnackBar(success: success, successMessage: '품절이 해제되었습니다.');
  }

  void _showActionResultSnackBar({
    required bool success,
    required String successMessage,
  }) {
    final message = success
        ? successMessage
        : context.read<BreadProvider>().errorMessage ?? '처리에 실패했습니다.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _BreadMenuCard extends StatelessWidget {
  const _BreadMenuCard({
    required this.bread,
    required this.onTap,
    required this.onToggleSoldOut,
  });

  final BreadCommonResponse bread;
  final VoidCallback onTap;
  final VoidCallback onToggleSoldOut;

  @override
  Widget build(BuildContext context) {
    final isSoldOut = bread.remainingQuantity == 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E4E4)),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          isSoldOut ? '현재 품절' : '수량 ${bread.remainingQuantity}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSoldOut
                                ? const Color(0xFFD2554C)
                                : const Color(0xFF6E6E6E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  _BreadThumbnail(imageUrl: bread.imageUrl),
                ],
              ),
              const SizedBox(height: 16),
              if (isSoldOut)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECEA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '품절',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFD2554C),
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              Center(
                child: SizedBox(
                  width: 148,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: onToggleSoldOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSoldOut
                          ? AppColors.primaryBackground
                          : const Color(0xFFE7776B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isSoldOut ? '품절 해제' : '품절 처리',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
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

class _BreadActionDialog extends StatelessWidget {
  const _BreadActionDialog({
    required this.title,
    required this.onClose,
    required this.child,
  });

  final String title;
  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: Colors.black),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _StockInputDialog extends StatefulWidget {
  const _StockInputDialog({required this.title});

  final String title;

  @override
  State<_StockInputDialog> createState() => _StockInputDialogState();
}

class _StockInputDialogState extends State<_StockInputDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BreadActionDialog(
      title: widget.title,
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '재고 수량을 입력해주세요.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6F6F6F)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            onChanged: (_) {
              if (_errorText == null || !mounted) {
                return;
              }
              setState(() {
                _errorText = null;
              });
            },
            decoration: InputDecoration(
              hintText: '예: 10',
              errorText: _errorText,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: SizedBox(
              width: 140,
              height: 46,
              child: ElevatedButton(
                onPressed: _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBackground,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleConfirm() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value <= 0) {
      setState(() {
        _errorText = '1개 이상 입력해주세요.';
      });
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(value);
    });
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
