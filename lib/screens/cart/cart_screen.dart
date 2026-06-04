import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todaybread/models/cart/cart_item_response.dart';
import 'package:todaybread/screens/order/purchase_screen.dart';
import 'package:todaybread/services/cart/cart_service.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/utils/app_colors.dart';
import 'package:todaybread/widgets/app_network_image.dart';

/// 장바구니 아이템 로컬 모델
class CartItem {
  final int cartItemId;
  final int breadId;
  final String name;
  final String description;
  final int price;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.cartItemId,
    required this.breadId,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.quantity,
  });

  factory CartItem.fromResponse(CartItemResponse r) => CartItem(
    cartItemId: r.cartItemId,
    breadId: r.breadId,
    name: r.breadName,
    description: r.description,
    price: r.salePrice,
    imageUrl: r.imageUrl,
    quantity: r.quantity,
  );
}

/// 장바구니 화면
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService.instance;

  List<CartItem> _items = [];
  String _storeName = '';
  Duration _remainingTime = Duration.zero;
  Timer? _timer;

  bool _isLoading = true;
  String? _loadError;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final response = await _cartService.getCart();
      if (!mounted) return;

      final items = response.items.map(CartItem.fromResponse).toList();

      setState(() {
        _items = items;
        _storeName = response.storeName ?? '';
        _remainingTime = _parseLastOrderTime(response.lastOrderTime);
        _isLoading = false;
      });

      if (_remainingTime > Duration.zero) {
        _startTimer();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = ApiException.messageFrom(e);
      });
    }
  }

  Duration _parseLastOrderTime(String? lastOrderTime) {
    if (lastOrderTime == null) return Duration.zero;
    final parts = lastOrderTime.split(':');
    if (parts.length < 2) return Duration.zero;
    final now = DateTime.now();
    final target = DateTime(
      now.year,
      now.month,
      now.day,
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts[1]) ?? 0,
      parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0,
    );
    final diff = target.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingTime.inSeconds <= 0) {
        _timer?.cancel();
        return;
      }
      setState(() {
        _remainingTime -= const Duration(seconds: 1);
      });
    });
  }

  int get _totalPrice =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  String get _remainingTimeText {
    final h = _remainingTime.inHours;
    final m = _remainingTime.inMinutes.remainder(60);
    final s = _remainingTime.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}분 ${s.toString().padLeft(2, '0')}초';
  }

  String get _remainingTimeShort {
    final h = _remainingTime.inHours;
    final m = _remainingTime.inMinutes.remainder(60);
    final s = _remainingTime.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          if (!_isLoading && _loadError == null) _buildBottomBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.onPrimaryBackground,
          size: 24,
        ),
      ),
      centerTitle: true,
      title: const Text(
        '장바구니',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.onPrimaryBackground,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _loadError!,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: _loadCart,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBackground,
                side: const BorderSide(color: AppColors.primaryBackground),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) return _buildEmptyState();
    return _buildCartContent();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.black87),
          const SizedBox(height: 16),
          const Text(
            '장바구니에 담긴 메뉴가 없습니다.',
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _buildStoreHeader(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _clearCart,
                icon: const Icon(
                  Icons.delete_sweep_outlined,
                  size: 18,
                  color: Colors.black45,
                ),
                label: const Text(
                  '장바구니 비우기',
                  style: TextStyle(fontSize: 13, color: Colors.black45),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedList(
            key: _listKey,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            initialItemCount: _items.length,
            itemBuilder: (context, index, animation) {
              return _buildAnimatedItemCard(_items[index], animation);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoreHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.store_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _storeName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
          ],
        ),
        if (_remainingTime > Duration.zero) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                '주문 종료까지 남은 시간: ',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              Text(
                _remainingTimeShort,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE53935),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _removeItem(CartItem item) async {
    final index = _items.indexOf(item);
    if (index == -1) return;

    // 낙관적 업데이트: 먼저 UI에서 제거
    final removed = _items[index];
    _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildAnimatedItemCard(removed, animation),
      duration: const Duration(milliseconds: 300),
    );
    setState(() {});

    try {
      await _cartService.deleteItem(item.cartItemId);
    } catch (e) {
      // 실패 시 재로드
      if (mounted) _loadCart();
    }
  }

  void _clearCart() async {
    final count = _items.length;
    final removed = List<CartItem>.from(_items);
    _items.clear();

    for (var i = count - 1; i >= 0; i--) {
      _listKey.currentState?.removeItem(
        i,
        (context, animation) => _buildAnimatedItemCard(removed[i], animation),
        duration: const Duration(milliseconds: 250),
      );
    }
    setState(() {});

    try {
      await _cartService.clearCart();
    } catch (e) {
      if (mounted) _loadCart();
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    final oldQuantity = item.quantity;
    setState(() {
      item.quantity = newQuantity;
    });

    try {
      await _cartService.updateItem(item.cartItemId, newQuantity);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        item.quantity = oldQuantity;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ApiException.messageFrom(e))));
    }
  }

  Widget _buildAnimatedItemCard(CartItem item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: _buildItemCard(item),
      ),
    );
  }

  Widget _buildItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '구성',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppNetworkImage(
                  imageUrl: item.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  placeholder: _breadImagePlaceholder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatPrice(item.price)}원',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              _buildQuantityControl(item),
            ],
          ),
        ],
      ),
    );
  }

  Widget _breadImagePlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6D3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.bakery_dining_rounded,
        color: Color(0xFFD4956A),
        size: 36,
      ),
    );
  }

  Widget _buildQuantityControl(CartItem item) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _removeItem(item),
          child: const Icon(
            Icons.delete_outline,
            size: 22,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: item.quantity > 1
              ? () => _updateQuantity(item, item.quantity - 1)
              : null,
          child: Icon(
            Icons.remove,
            size: 22,
            color: item.quantity > 1 ? Colors.black87 : Colors.black26,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${item.quantity}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _updateQuantity(item, item.quantity + 1),
          child: const Icon(Icons.add, size: 22, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_items.isNotEmpty && _remainingTime > Duration.zero)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: const Color(0xFFFFF0EC),
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                  children: [
                    const TextSpan(text: '가게 주문 마감까지 '),
                    TextSpan(
                      text: _remainingTimeText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE87840),
                      ),
                    ),
                    const TextSpan(text: ' 남았어요!!'),
                  ],
                ),
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '결제 금액',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatPrice(_totalPrice)}원',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _items.isEmpty ? null : _openPurchaseFlow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBackground,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '구매하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimaryBackground,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  Future<void> _openPurchaseFlow() async {
    final purchaseItems = _items
        .map(
          (item) => PurchaseItem(
            name: item.name,
            unitPrice: item.price,
            quantity: item.quantity,
          ),
        )
        .toList();

    await showPurchaseNoticeAndOpenScreen(
      context,
      items: purchaseItems,
      storeName: _storeName,
    );
  }
}
