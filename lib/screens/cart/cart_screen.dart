import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todaybread/utils/app_colors.dart';

/// 장바구니 아이템 모델 (로컬 상태용)
class CartItem {
  final String name;
  final String ingredients;
  final int price;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.name,
    required this.ingredients,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
  });
}

/// 장바구니 화면
///
/// - 담긴 상품이 있을 때: 가게명 + 주문 마감 타이머 + 상품 목록 + 결제 바
/// - 담긴 상품이 없을 때: 빈 상태 안내 + 결제 바
class CartScreen extends StatefulWidget {
  /// 더미 데이터 여부 (개발 중 미리보기용)
  final bool useDummyData;

  const CartScreen({super.key, this.useDummyData = true});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  /// 장바구니에 담긴 상품 목록
  late List<CartItem> _items;

  /// 가게명
  final String _storeName = '파리바게트 한성대입구역점';

  /// 주문 마감까지 남은 시간 (초)
  Duration _remainingTime = const Duration(minutes: 45, seconds: 3);

  Timer? _timer;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _items = widget.useDummyData ? _buildDummyItems() : [];
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<CartItem> _buildDummyItems() {
    const ingredients = '중력분, 설탕, 버터, 땅콩버터, 물엿, 베이킹 파우더\n강력분, 우유, 달걀, 이스트, 소금, 설탕';
    return [
      CartItem(name: '소보루 빵', ingredients: ingredients, price: 700),
      CartItem(name: '꽈배기', ingredients: ingredients, price: 800),
      CartItem(name: '붕어빵', ingredients: ingredients, price: 1800),
    ];
  }

  void _startTimer() {
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
          Expanded(
            child: _items.isEmpty ? _buildEmptyState() : _buildCartContent(),
          ),
          _buildBottomBar(),
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
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
      ),
      centerTitle: true,
      title: const Text(
        '장바구니',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  /// 빈 장바구니 상태
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.black87,
          ),
          const SizedBox(height: 16),
          const Text(
            '장바구니에 담긴 메뉴가 없습니다.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  /// 장바구니 내용 (가게 헤더 + 아이템 목록)
  Widget _buildCartContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: _buildStoreHeader(),
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

  /// 가게명 + 주문 마감 타이머
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
            const Icon(
              Icons.chevron_right,
              color: Colors.black54,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text(
              '주문 종료까지 남은 시간: ',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
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
    );
  }

  void _removeItem(CartItem item) {
    final index = _items.indexOf(item);
    if (index == -1) return;

    final removed = _items[index];
    _items.removeAt(index);

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildAnimatedItemCard(removed, animation),
      duration: const Duration(milliseconds: 300),
    );

    // 모두 삭제됐을 때 빈 상태로 전환
    setState(() {});
  }

  /// 애니메이션 래핑 카드 (삭제 시 fade + slide up)
  Widget _buildAnimatedItemCard(CartItem item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: _buildItemCard(item),
      ),
    );
  }

  /// 개별 상품 카드
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
              /// 상품 정보
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.ingredients,
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

              /// 상품 이미지
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _breadImagePlaceholder(),
                      )
                    : _breadImagePlaceholder(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 가격 + 수량 조절
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

  /// 수량 조절 (삭제 아이콘 + 숫자 + + 버튼)
  Widget _buildQuantityControl(CartItem item) {
    return Row(
      children: [
        /// 삭제 버튼
        GestureDetector(
          onTap: () => _removeItem(item),
          child: const Icon(
            Icons.delete_outline,
            size: 22,
            color: Colors.black54,
          ),
        ),

        const SizedBox(width: 10),

        /// 수량
        Text(
          '${item.quantity}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        const SizedBox(width: 10),

        /// + 버튼
        GestureDetector(
          onTap: () {
            setState(() {
              item.quantity++;
            });
          },
          child: const Icon(
            Icons.add,
            size: 22,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// 하단 바 (타이머 배너 + 결제 금액 + 구매 버튼)
  Widget _buildBottomBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// 마감 시간 배너 (아이템이 있을 때만)
        if (_items.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: const Color(0xFFFFF0EC),
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
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

        /// 결제 금액 + 구매하기 버튼
        Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
            ),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '결제 금액',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
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
                    onPressed: _items.isEmpty ? null : () {},
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
                        color: Colors.white,
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
}
