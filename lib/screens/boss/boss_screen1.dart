import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/user/user_profile_provider.dart';
import 'package:todaybread/screens/boss/boss_screen2.dart';
import 'package:todaybread/screens/boss/boss_screen3.dart';
import 'package:todaybread/screens/boss/boss_screen4.dart';
import 'package:todaybread/screens/boss/boss_screen5.dart';
import 'package:todaybread/screens/boss/boss_screen6.dart';
import 'package:todaybread/utils/app_colors.dart';

class BossScreen1 extends StatelessWidget {
  const BossScreen1({super.key});

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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBackground, Color(0xFF2F8E84)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '사업자 계정 이용중',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '매장과 메뉴, 주문과 리뷰를 한 곳에서 관리해보세요.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Color(0xFFF2FFFC),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: const [
                        _BossStatusChip(label: '매장 관리'),
                        SizedBox(width: 8),
                        _BossStatusChip(label: '메뉴 관리'),
                        SizedBox(width: 8),
                        _BossStatusChip(label: '주문 확인'),
                      ],
                    ),
                  ],
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
                onTap: () => _push(context, const BossScreen2()),
              ),
              const SizedBox(height: 12),
              _BossMenuTile(
                title: '메뉴관리',
                subtitle: '메뉴 추가와 수정, 품절 처리를 진행합니다.',
                icon: Icons.restaurant_menu_outlined,
                onTap: () => _push(context, const BossScreen3()),
              ),
              const SizedBox(height: 12),
              _BossMenuTile(
                title: '매출관리',
                subtitle: '일별/월별 매출 현황을 확인합니다.',
                icon: Icons.bar_chart_rounded,
                onTap: () => _push(context, const BossScreen4()),
              ),
              const SizedBox(height: 12),
              _BossMenuTile(
                title: '리뷰관리',
                subtitle: '고객 리뷰를 확인하고 관리합니다.',
                icon: Icons.rate_review_outlined,
                onTap: () => _push(context, const BossScreen5()),
              ),
              const SizedBox(height: 12),
              _BossMenuTile(
                title: '주문내역',
                subtitle: '접수된 주문과 처리 상태를 확인합니다.',
                icon: Icons.receipt_long_outlined,
                onTap: () => _push(context, const BossScreen6()),
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

class _BossStatusChip extends StatelessWidget {
  final String label;

  const _BossStatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
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
