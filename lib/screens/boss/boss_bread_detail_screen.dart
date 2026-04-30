import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/models/bread/bread_common_response.dart';
import 'package:todaybread/providers/bread/bread_provider.dart';
import 'package:todaybread/services/network/dio_client.dart';
import 'package:todaybread/utils/app_colors.dart';

class BossBreadDetailScreen extends StatefulWidget {
  const BossBreadDetailScreen({super.key, required this.bread});

  final BreadCommonResponse bread;

  @override
  State<BossBreadDetailScreen> createState() => _BossBreadDetailScreenState();
}

class _BossBreadDetailScreenState extends State<BossBreadDetailScreen> {
  late BreadCommonResponse _bread;
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _bread = widget.bread;
    _quantityController = TextEditingController(
      text: _bread.remainingQuantity.toString(),
    )..addListener(_onQuantityChanged);
  }

  @override
  void dispose() {
    _quantityController
      ..removeListener(_onQuantityChanged)
      ..dispose();
    super.dispose();
  }

  int? get _parsedQuantity => int.tryParse(_quantityController.text.trim());

  bool get _hasQuantityChanged {
    final value = _parsedQuantity;
    return value != null &&
        value >= 0 &&
        value != _bread.remainingQuantity;
  }

  @override
  Widget build(BuildContext context) {
    final breadProvider = context.watch<BreadProvider>();
    final isSaving = breadProvider.isLoading;

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
          child: Container(
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
                Center(child: _BreadDetailImage(imageUrl: _bread.imageUrl)),
                const SizedBox(height: 22),
                _DetailRow(
                  title: '메뉴명',
                  child: _StaticValue(text: _bread.name),
                ),
                const Divider(height: 28, color: Color(0xFFEAEAEA)),
                _DetailRow(
                  title: '원가',
                  child: _StaticValue(text: '${_formatPrice(_bread.originalPrice)}원'),
                ),
                const Divider(height: 28, color: Color(0xFFEAEAEA)),
                _DetailRow(
                  title: '할인가',
                  child: _StaticValue(text: '${_formatPrice(_bread.salePrice)}원'),
                ),
                const Divider(height: 28, color: Color(0xFFEAEAEA)),
                _DetailRow(
                  title: '상품 설명',
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
                        enabled: (_parsedQuantity ?? _bread.remainingQuantity) > 0,
                        onTap: _decreaseQuantity,
                      ),
                      Container(
                        width: 88,
                        height: 52,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD8D8D8)),
                        ),
                        child: TextField(
                          controller: _quantityController,
                          enabled: !isSaving,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
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
                              disabledBackgroundColor: const Color(0xFFD8D8D8),
                              foregroundColor: Colors.white,
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
              context.read<BreadProvider>().errorMessage ??
                  '수량 변경에 실패했습니다.',
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

class _BreadDetailImage extends StatelessWidget {
  const _BreadDetailImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveBreadImageUrl(imageUrl);

    if (resolvedUrl == null) {
      return _buildFallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.network(
        resolvedUrl,
        width: 180,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallback(),
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

String? _resolveBreadImageUrl(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  return '${DioClient.baseUrl}$value';
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF7E7E7E),
          ),
        ),
        const SizedBox(height: 10),
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
