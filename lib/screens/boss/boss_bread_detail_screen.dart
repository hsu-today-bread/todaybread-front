import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/models/bread/bread_common_response.dart';
import 'package:todaybread/providers/bread/bread_provider.dart';
import 'package:todaybread/providers/store/store_provider.dart';
import 'package:todaybread/screens/boss/boss_bread_create_screen.dart';
import 'package:todaybread/utils/app_colors.dart';
import 'package:todaybread/utils/business_hours_helper.dart';
import 'package:todaybread/utils/display_helper.dart';
import 'package:todaybread/widgets/app_network_image.dart';

class BossBreadDetailScreen extends StatefulWidget {
  const BossBreadDetailScreen({super.key, required this.bread});

  final BreadCommonResponse bread;

  @override
  State<BossBreadDetailScreen> createState() => _BossBreadDetailScreenState();
}

class _BossBreadDetailScreenState extends State<BossBreadDetailScreen> {
  late BreadCommonResponse _bread;
  late final TextEditingController _quantityController;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _bread = widget.bread;
    _quantityController = TextEditingController(
      text: _bread.remainingQuantity.toString(),
    )..addListener(_onQuantityChanged);
    _startClockTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final storeProvider = context.read<StoreProvider>();
      if (storeProvider.storeInfo == null && !storeProvider.isLoading) {
        unawaited(storeProvider.fetchStatus());
      }
    });
  }

  @override
  void dispose() {
    _quantityController
      ..removeListener(_onQuantityChanged)
      ..dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  int? get _parsedQuantity => int.tryParse(_quantityController.text.trim());

  bool get _hasQuantityChanged {
    final value = _parsedQuantity;
    return value != null && value >= 0 && value != _bread.remainingQuantity;
  }

  @override
  Widget build(BuildContext context) {
    final breadProvider = context.watch<BreadProvider>();
    final storeProvider = context.watch<StoreProvider>();
    final isSaving = breadProvider.isLoading;
    final remainingTimeText = _buildRemainingTimeText(storeProvider);

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
          '메뉴 상세',
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE7E7E7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: _EditableImage(
                        imageUrl: _bread.imageUrl,
                        onEdit: () => _openEdit(initialStep: 2),
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (remainingTimeText != null) ...[
                      _DetailRow(
                        title: '남은 시간',
                        child: _StaticValue(text: remainingTimeText),
                      ),
                      const Divider(height: 28, color: Color(0xFFEAEAEA)),
                    ],
                    _DetailRow(
                      title: '메뉴명',
                      onEdit: () => _openEdit(initialStep: 0),
                      child: _StaticValue(text: _bread.name),
                    ),
                    const Divider(height: 28, color: Color(0xFFEAEAEA)),
                    _DetailRow(
                      title: '원가',
                      onEdit: () => _openEdit(initialStep: 1),
                      child: _StaticValue(
                        text: '${_formatPrice(_bread.originalPrice)}원',
                      ),
                    ),
                    const Divider(height: 28, color: Color(0xFFEAEAEA)),
                    _DetailRow(
                      title: '할인가',
                      onEdit: () => _openEdit(initialStep: 1),
                      child: _StaticValue(
                        text: '${_formatPrice(_bread.salePrice)}원',
                      ),
                    ),
                    const Divider(height: 28, color: Color(0xFFEAEAEA)),
                    _DetailRow(
                      title: '상품 설명',
                      onEdit: () => _openEdit(initialStep: 3),
                      child: _DescriptionValue(
                        text: _bread.description.isEmpty
                            ? '등록된 상품 설명이 없습니다.'
                            : _bread.description,
                      ),
                    ),
                    const Divider(height: 28, color: Color(0xFFEAEAEA)),
                    _DetailRow(
                      title: '수량',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _QuantityActionButton(
                            label: '-',
                            enabled:
                                (_parsedQuantity ?? _bread.remainingQuantity) >
                                0,
                            onTap: _decreaseQuantity,
                          ),
                          Container(
                            width: 88,
                            height: 52,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFD8D8D8),
                              ),
                            ),
                            child: TextField(
                              controller: _quantityController,
                              enabled: !isSaving,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          _QuantityActionButton(
                            label: '+',
                            enabled: !isSaving,
                            onTap: _increaseQuantity,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: !isSaving && _hasQuantityChanged
                                    ? _submitQuantityChange
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBackground,
                                  disabledBackgroundColor: const Color(
                                    0xFFD8D8D8,
                                  ),
                                  foregroundColor:
                                      AppColors.onPrimaryBackground,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  isSaving ? '처리 중...' : '확인',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _confirmDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBackground,
                    disabledBackgroundColor: const Color(0xFFD8D8D8),
                    foregroundColor: AppColors.onPrimaryBackground,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isSaving ? '처리 중...' : '메뉴 삭제',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
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

  void _onQuantityChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _startClockTimer() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  String? _buildRemainingTimeText(StoreProvider storeProvider) {
    final store = storeProvider.storeInfo?.store;
    if (store == null) {
      return null;
    }

    String? todayLastOrderTime;
    for (final value in store.businessHours) {
      if (value.dayOfWeek == DateTime.now().weekday) {
        todayLastOrderTime = value.lastOrderTime;
        break;
      }
    }

    return DisplayHelper.buildLastOrderRemainingTimeText(
      isSelling:
          _bread.remainingQuantity > 0 && isStoreOpenNow(store.businessHours),
      lastOrderTime: todayLastOrderTime,
      includeSeconds: true,
    );
  }

  void _decreaseQuantity() {
    final current = _parsedQuantity ?? _bread.remainingQuantity;
    if (current <= 0) {
      return;
    }
    _quantityController.text = '${current - 1}';
  }

  void _increaseQuantity() {
    final current = _parsedQuantity ?? _bread.remainingQuantity;
    _quantityController.text = '${current + 1}';
  }

  Future<void> _submitQuantityChange() async {
    final value = _parsedQuantity;
    if (value == null || value < 0) {
      return;
    }

    final success = await context.read<BreadProvider>().updateBreadStock(
      breadId: _bread.id,
      remainingQuantity: value,
    );
    if (!mounted) {
      return;
    }
    if (!success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.read<BreadProvider>().errorMessage ?? '수량 변경에 실패했습니다.',
            ),
          ),
        );
      return;
    }

    setState(() {
      _bread = _bread.copyWith(remainingQuantity: value);
      _quantityController.text = value.toString();
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('수량이 변경되었습니다.')));
  }

  Future<void> _openEdit({required int initialStep}) async {
    final updatedBread = await Navigator.push<BreadCommonResponse>(
      context,
      MaterialPageRoute(
        builder: (_) => BossBreadCreateScreen(
          initialBread: _bread,
          initialStep: initialStep,
        ),
      ),
    );
    if (!mounted || updatedBread == null) {
      return;
    }

    setState(() {
      _bread = updatedBread;
      _quantityController.text = updatedBread.remainingQuantity.toString();
    });
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text('메뉴 삭제'),
          content: const Text('이 메뉴를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryBackground,
                foregroundColor: AppColors.onPrimaryBackground,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final success = await context.read<BreadProvider>().deleteBread(_bread.id);
    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.read<BreadProvider>().errorMessage ?? '메뉴 삭제에 실패했습니다.',
            ),
          ),
        );
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('메뉴가 삭제되었습니다.')));
    Navigator.of(context).pop();
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

class _EditableImage extends StatelessWidget {
  const _EditableImage({required this.imageUrl, required this.onEdit});

  final String? imageUrl;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _BreadDetailImage(imageUrl: imageUrl),
        Positioned(
          right: 0,
          top: 0,
          child: Material(
            color: AppColors.primaryBackground,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onEdit,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.edit_outlined, size: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BreadDetailImage extends StatelessWidget {
  const _BreadDetailImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AppNetworkImage(
        imageUrl: imageUrl,
        width: 180,
        height: 180,
        fit: BoxFit.cover,
        placeholder: _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFF9B9B9B),
        size: 44,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.title, required this.child, this.onEdit});

  final String title;
  final Widget child;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7E7E7E),
                ),
              ),
            ),
            if (onEdit != null)
              IconButton(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Color(0xFF6F6F6F),
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _StaticValue extends StatelessWidget {
  const _StaticValue({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.black,
      ),
    );
  }
}

class _DescriptionValue extends StatelessWidget {
  const _DescriptionValue({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: Color(0xFF2F2F2F),
      ),
    );
  }
}

class _QuantityActionButton extends StatelessWidget {
  const _QuantityActionButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.primaryBackground
                : const Color(0xFFD8D8D8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
