import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/user/user_profile_provider.dart';
import 'package:todaybread/screens/boss/boss_bread_management_screen.dart';
import 'package:todaybread/screens/boss/boss_order_history_screen.dart';
import 'package:todaybread/screens/boss/boss_review_management_screen.dart';
import 'package:todaybread/screens/boss/boss_sales_screen.dart';
import 'package:todaybread/screens/boss/boss_store_management_screen.dart';
import 'package:todaybread/utils/app_colors.dart';

/// 사장님 홈 화면입니다.
///
/// 각 관리 메뉴의 진입점 역할만 담당하고,
/// 실제 상세 관리 화면은 각 도메인 화면으로 바로 연결합니다.
class BossDashboardScreen extends StatelessWidget {
  const BossDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nickname = context.watch<UserProfileProvider>().nickname;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$nickname님',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x16000000),
                          blurRadius: 14,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '오늘의 판매금액',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF757575),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '0원',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: () {
                    // TODO: Replace with the finalized boss order-history screen flow.
                    _push(context, const BossOrderHistoryScreen());
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Ink(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 18,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '주문내역 확인하기',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '주문 내역은 실시간으로 확인해주세요',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '>',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9A9A9A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '관리 메뉴',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),
              _BossMenuTile(
                title: '매장관리',
                subtitle: '매장 정보와 운영 상태를 관리합니다.',
                icon: Icons.store_mall_directory_outlined,
                onTap: () => _push(context, const BossStoreManagementScreen()),
              ),
              const SizedBox(height: 12),
              _BossMenuTile(
                title: '메뉴관리',
                subtitle: '메뉴 추가와 수정, 품절 처리를 진행합니다.',
                icon: Icons.restaurant_menu_outlined,
                onTap: () => _push(context, const BossBreadManagementScreen()),
              ),
              const SizedBox(height: 12),
              _BossMenuTile(
                title: '매출관리',
                subtitle: '일별/월별 매출 현황을 확인합니다.',
                icon: Icons.bar_chart_rounded,
                onTap: () => _push(context, const BossSalesScreen()),
              ),
              const SizedBox(height: 12),
              _BossMenuTile(
                title: '리뷰관리',
                subtitle: '고객 리뷰를 확인하고 관리합니다.',
                icon: Icons.rate_review_outlined,
                onTap: () => _push(context, const BossReviewManagementScreen()),
              ),
              const SizedBox(height: 12),
              _BossMenuTile(
                title: '주문내역',
                subtitle: '접수된 주문과 처리 상태를 확인합니다.',
                icon: Icons.receipt_long_outlined,
                onTap: () => _push(context, const BossOrderHistoryScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _BossMenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _BossMenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}
