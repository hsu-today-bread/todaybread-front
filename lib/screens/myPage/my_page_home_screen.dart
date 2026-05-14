import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/models/order/order_detail_response.dart';
import 'package:todaybread/models/order/order_item_response.dart';
import 'package:todaybread/models/order/order_response.dart';
import 'package:todaybread/models/review/my_review_response.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/providers/user/user_profile_provider.dart';
import 'package:todaybread/screens/boss/boss_review_management_screen.dart';
import 'package:todaybread/screens/boss/boss_store_management_screen.dart';
import 'package:todaybread/screens/review/review_create_screen.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/order/order_service.dart';
import 'package:todaybread/services/review/review_service.dart';
import 'package:todaybread/widgets/app_network_image.dart';
import '../../utils/app_colors.dart';
import 'boss_account_verification_screen.dart';
import 'my_profile_screen.dart';

/// 마이페이지 메인 화면
/// 프로필 요약, 계정 상태, 주문 내역을 보여준다.
class MyPageHomeScreen extends StatefulWidget {
  const MyPageHomeScreen({super.key, this.orderRefreshSignal = 0});

  final int orderRefreshSignal;

  @override
  State<MyPageHomeScreen> createState() => _MyPageHomeScreenState();
}

class _MyPageHomeScreenState extends State<MyPageHomeScreen> {
  List<OrderResponse> _orders = [];
  Map<int, OrderDetailResponse> _orderDetails = {};
  List<MyReviewResponse> _myReviews = [];
  final Set<int> _reviewedOrderItemIds = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void didUpdateWidget(covariant MyPageHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderRefreshSignal != widget.orderRefreshSignal) {
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _orderDetails = {};
    });
    try {
      final result = await OrderService.instance.getOrders();
      final details = <int, OrderDetailResponse>{};
      var myReviews = _myReviews;
      await Future.wait([
        Future.wait(
          result.content.map((order) async {
            try {
              details[order.orderId] = await OrderService.instance
                  .getOrderDetail(order.orderId);
            } catch (_) {
              // 목록 표시 자체는 가능해야 하므로 상세 조회 실패는 카드 fallback으로 처리한다.
            }
          }),
        ),
        ReviewService.instance
            .getMyReviews()
            .then((value) => myReviews = value.content)
            .catchError((_) => myReviews = _myReviews),
      ]);
      if (!mounted) return;
      setState(() {
        _orders = result.content;
        _orderDetails = details;
        _myReviews = myReviews;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ApiException.messageFrom(e);
        _orderDetails = {};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBoss = context.watch<AuthProvider>().isBoss;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileSection(),
                    const SizedBox(height: 18),
                    _buildAccountCard(),
                    const SizedBox(height: 20),
                    isBoss
                        ? _buildBossManagementSection()
                        : _buildReviewSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    final nickname = context.watch<UserProfileProvider>().nickname;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE3E3E3), width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFF2C9),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile_sample.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    size: 52,
                    color: Colors.brown,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 72),
              Expanded(
                child: Text(
                  nickname,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(
                width: 72,
                height: 30,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyProfileScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0E0E0),
                    foregroundColor: Colors.grey[700],
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    '내 정보 보기',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    final isBoss = context.watch<AuthProvider>().isBoss;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: isBoss
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BossAccountVerificationScreen(),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
            border: Border.all(color: const Color(0xFFE6E6E6)),
          ),
          child: Row(
            children: [
              if (isBoss)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CD964),
                  size: 20,
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBoss ? '사업자 계정 이용중' : '일반 사용자 계정 이용중',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBoss
                          ? '사업자 인증이 완료된 계정입니다.'
                          : '사업자 번호 입력하고 사장님 계정으로 변경하기',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9A9A9A),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isBoss)
                const Icon(
                  Icons.chevron_right,
                  size: 28,
                  color: Color(0xFF8E8E8E),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '주문 내역',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E8E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _loadOrders,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBackground,
                      side: const BorderSide(
                        color: AppColors.primaryBackground,
                      ),
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            )
          else if (_orders.isEmpty)
            _buildEmptyReviewState()
          else
            ..._orders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildOrderCard(order),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBossManagementSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '사장님 관리',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          _buildBossMenuCard(
            title: '매장관리',
            subtitle: '매장 정보와 운영 상태를 관리합니다.',
            icon: Icons.store_mall_directory_outlined,
            onTap: () => _push(const BossStoreManagementScreen()),
          ),
          const SizedBox(height: 12),
          _buildBossMenuCard(
            title: '리뷰관리',
            subtitle: '고객 리뷰를 확인하고 관리합니다.',
            icon: Icons.rate_review_outlined,
            onTap: () => _push(const BossReviewManagementScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildBossMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8E8E8)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF818181),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 28,
                color: Color(0xFF9A9A9A),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildEmptyReviewState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '주문 내역이 없습니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8E8E8E),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 180,
              height: 180,
              child: Lottie.asset('assets/lottie/emptyCart.json'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderResponse order) {
    final detail = _orderDetails[order.orderId];
    final items = detail?.items ?? const <OrderItemResponse>[];
    final firstItem = items.isNotEmpty ? items.first : null;
    final reviewItem = _findReviewableItem(items);
    final menuText = _buildOrderMenuText(items, order);
    final formattedPrice = _formatPrice(order.totalAmount);
    final dateText = _formatOrderDate(order.createdAt);
    final canReview = order.status == 'PICKED_UP';
    final hasWrittenReview = _hasWrittenReview(order, items);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E4E4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9B9B9B),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 72,
                        height: 72,
                        color: const Color(0xFFFFE8E1),
                        child: AppNetworkImage(
                          imageUrl: firstItem?.breadImageUrl,
                          fit: BoxFit.cover,
                          placeholder: const Icon(
                            Icons.bakery_dining_outlined,
                            color: Colors.brown,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.storeName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              menuText,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6F6F6F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
            child: Row(
              children: [
                const Text('💳', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                const Text(
                  '결제 금액',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  '$formattedPrice원',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: canReview
                    ? () => hasWrittenReview
                          ? _openWrittenReview(order, items)
                          : _openReviewScreen(order, detail, reviewItem)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBackground,
                  disabledBackgroundColor: AppColors.primaryBackground,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  canReview
                      ? hasWrittenReview
                            ? '내가 쓴 리뷰 보기'
                            : '리뷰 작성 >'
                      : '주문 번호 : ${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openReviewScreen(
    OrderResponse order,
    OrderDetailResponse? detail,
    OrderItemResponse? item,
  ) async {
    OrderDetailResponse currentDetail;
    try {
      currentDetail = await OrderService.instance.getOrderDetail(order.orderId);
    } catch (e) {
      if (detail == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(ApiException.messageFrom(e))));
        return;
      }
      currentDetail = detail;
    }

    if (mounted) {
      setState(() {
        _orderDetails[order.orderId] = currentDetail;
      });
    }

    final reviewItem = item?.orderItemId == null
        ? _findReviewableItem(currentDetail.items)
        : item;
    if (reviewItem == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('리뷰를 작성할 주문 항목 ID가 없습니다.')));
      return;
    }

    if (!mounted) return;
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            ReviewCreateScreen(order: currentDetail, item: reviewItem),
      ),
    );

    if (created == true && mounted) {
      final orderItemId = reviewItem.orderItemId;
      if (orderItemId != null) {
        _reviewedOrderItemIds.add(orderItemId);
      }
      await _refreshMyReviews();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('리뷰가 등록되었습니다.')));
      setState(() {});
    }
  }

  Future<void> _refreshMyReviews() async {
    try {
      final response = await ReviewService.instance.getMyReviews();
      if (!mounted) return;
      setState(() {
        _myReviews = response.content;
      });
    } catch (_) {
      // 리뷰 작성 자체는 성공했으므로 목록 조회 실패는 버튼 클릭 시 토스트로 처리한다.
    }
  }

  Future<void> _openWrittenReview(
    OrderResponse order,
    List<OrderItemResponse> items,
  ) async {
    var reviews = _matchingReviews(order, items);
    if (reviews.isEmpty) {
      await _refreshMyReviews();
      reviews = _matchingReviews(order, items);
    }

    if (!mounted) return;
    if (reviews.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('작성한 리뷰를 불러올 수 없습니다.')));
      return;
    }

    _showMyReviewSheet(reviews.first);
  }

  void _showMyReviewSheet(MyReviewResponse review) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  review.storeName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  review.breadName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6F6F6F),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: Color(0xFFFFC107),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${review.rating.toInt()}점',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  review.content.isEmpty ? '작성된 리뷰 내용이 없습니다.' : review.content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202020),
                  ),
                ),
                if (review.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: review.imageUrls.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          review.imageUrls[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: const Color(0xFFEEEEEE),
                            child: const Icon(Icons.broken_image_outlined,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _buildOrderMenuText(
    List<OrderItemResponse> items,
    OrderResponse order,
  ) {
    if (items.isEmpty) {
      return '주문번호 ${order.orderNumber}';
    }
    return items
        .map((item) => '${item.breadName} ${item.quantity}개')
        .join(', ');
  }

  OrderItemResponse? _findReviewableItem(List<OrderItemResponse> items) {
    for (final item in items) {
      if (item.orderItemId != null) {
        return item;
      }
    }
    return null;
  }

  bool _hasWrittenReview(OrderResponse order, List<OrderItemResponse> items) {
    final orderItemIds = items
        .map((item) => item.orderItemId)
        .whereType<int>()
        .toSet();
    if (_reviewedOrderItemIds.any(orderItemIds.contains)) {
      return true;
    }
    if (_myReviews.any(
      (review) =>
          review.orderItemId != null &&
          orderItemIds.contains(review.orderItemId),
    )) {
      return true;
    }
    return _matchingReviews(order, items).isNotEmpty;
  }

  List<MyReviewResponse> _matchingReviews(
    OrderResponse order,
    List<OrderItemResponse> items,
  ) {
    final orderItemIds = items
        .map((item) => item.orderItemId)
        .whereType<int>()
        .toSet();
    final exactMatches = _myReviews
        .where(
          (review) =>
              review.orderItemId != null &&
              orderItemIds.contains(review.orderItemId),
        )
        .toList();
    if (exactMatches.isNotEmpty) {
      return exactMatches;
    }

    final breadNames = items.map((item) => item.breadName).toSet();
    return _myReviews
        .where(
          (review) =>
              review.storeName == order.storeName &&
              breadNames.contains(review.breadName),
        )
        .toList();
  }

  String _formatOrderDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value.isEmpty ? '구매일 확인 중' : '구매 $value';
    }
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '구매 ${parsed.month}월 ${parsed.day}일 (${weekdays[parsed.weekday - 1]})';
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
