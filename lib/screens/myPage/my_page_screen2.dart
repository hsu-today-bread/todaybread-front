import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/local/user_local_store.dart';
import 'my_page_screen3.dart';
import 'my_page_screen4.dart';
import 'my_page_screen5.dart';

/// 마이페이지 프로필 상세 화면
class MyPageScreen2 extends StatefulWidget {
  const MyPageScreen2({super.key});
  @override
  State<MyPageScreen2> createState() => _MyPageScreen2State();
}

class _MyPageScreen2State extends State<MyPageScreen2> {
  final nicknameController = TextEditingController(
    text: UserLocalStore.getNickname(),
  );
  final nameController = TextEditingController(text: UserLocalStore.getName());
  final phoneController = TextEditingController(
    text: UserLocalStore.getPhone(),
  );

  // TODO: 백엔드에 현재 로그인 사용자 정보 조회 API(예: GET /api/user/me)가 추가되면
  // 닉네임 / 이름 / 휴대폰 번호를 더미 문자열이 아니라 실제 응답값으로 교체할 것.
  //
  // TODO: 백엔드에 수정 API(예: PATCH /api/user/me)가 추가되면
  // 각 항목 탭 시 수정 화면 또는 바텀시트로 연결할 것.
  //
  // TODO: 로그아웃 API(POST /api/auth/logout)와 연결되면
  // 저장된 JWT 토큰 삭제 후 로그인 화면으로 이동 처리할 것.

  @override
  void dispose() {
    nicknameController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF7F7F7),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      children: [
                        _buildProfileImage(),
                        const SizedBox(height: 32),
                        _buildMenuCard(),
                      ],
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: SizedBox(
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
                '나의 프로필',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD9E8FF),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/profile_sample.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.brown,
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              right: 18,
              bottom: 16,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  size: 18,
                  color: Color(0xFF9A9A9A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          // 사용자 정보 조회 API 연동 후 실제 로그인한 사용자의 값으로 교체해야 합니다.
          _buildMenuRow(
            title: '닉네임',
            value: nicknameController.text.toString(),
            onTap: () => _openEditScreen(const MyPageScreen3()),
            isFirst: true,
          ),
          _buildDivider(),
          _buildMenuRow(
            title: '이름',
            value: nameController.text.toString(),
            onTap: () => _openEditScreen(const MyPageScreen4()),
          ),
          _buildDivider(),
          _buildMenuRow(
            title: '휴대폰 번호 변경',
            value: phoneController.text.toString(),
            onTap: () => _openEditScreen(const MyPageScreen5()),
          ),
          _buildDivider(),
          _buildMenuRow(
            title: '로그아웃',
            onTap: () {
              // TODO: 로그아웃 API 연동 및 토큰 삭제 처리
            },
          ),
          _buildDivider(),
          _buildMenuRow(
            title: '회원 탈퇴',
            onTap: () {
              // TODO: 회원 탈퇴 API 연동
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFEAEAEA)),
    );
  }

  Widget _buildMenuRow({
    required String title,
    String? value,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            if (value != null) ...[
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9C9C9C),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              size: 26,
              color: Color(0xFF8F8F8F),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditScreen(Widget screen) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );

    if (result == true && mounted) {
      setState(() {
        nicknameController.text = UserLocalStore.getNickname();
        nameController.text = UserLocalStore.getName();
        phoneController.text = UserLocalStore.getPhone();
      });
    }
  }
}
