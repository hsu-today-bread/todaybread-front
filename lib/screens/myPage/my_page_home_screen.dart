import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/models/order/order_response.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/providers/user/user_profile_provider.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/order/order_service.dart';
import 'package:todaybread/utils/display_helper.dart';
import '../../utils/app_colors.dart';
import 'boss_account_verification_screen.dart';
import 'my_profile_screen.dart';

/// 마이페이지 메인 화면
/// 프로필 요약, 계정 상태, 주문 내역을 보여준다.
class MyPageHomeScreen extends StatefulWidget {
  const MyPageHomeScreen({super.key});

  @override
  State<MyPageHomeScreen> createState() => _MyPageHomeScreenState();
}

class _MyPageHomeScreenState extends State<MyPageHomeScreen> {
  List<OrderResponse> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await OrderService.instance.getOrders();
      if (!mounted) return;
      setState(() {
        _orders = result.orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ApiException.messageFrom(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildReviewSection(),
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
                    style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E8E)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _loadOrders,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBackground,
                      side: const BorderSide(color: AppColors.primaryBackground),
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            )
          else if (_orders.isEmpty)
            _buildEmptyReviewState()
          else
            ..._orders.map((order) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildOrderCard(order),
                )),
        ],
      ),
    );
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
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final extraCount = order.items.length - 1;
    final menuText = firstItem == null
        ? '상품 정보 없음'
        : extraCount > 0
            ? '${firstItem.breadName} 외 $extraCount개'
            : firstItem.breadName;
    final imageUrl = DisplayHelper.resolveImageUrl(firstItem?.imageUrl);
    final formattedPrice = _formatPrice(order.totalPrice);
    final formattedDate = order.orderedAt.length >= 10
        ? order.orderedAt.substring(0, 10)
        : order.orderedAt;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E4E4)),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9B9B9B)),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFFFFE8E1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, e, st) => const Icon(
                                  Icons.cake_outlined,
                                  color: Colors.brown,
                                  size: 28,
                                ),
                              )
                            : const Icon(
                                Icons.cake_outlined,
                                color: Colors.brown,
                                size: 28,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.storeName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              menuText,
                              style: const TextStyle(
                                fontSize: 12,
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
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                const Icon(Icons.attach_money, size: 18, color: Color(0xFF53C4B7)),
                const Text(
                  '결제금액',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const Spacer(),
                Text(
                  '$formattedPrice원',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
