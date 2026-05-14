import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/interest_area/interest_area_provider.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/providers/user/user_profile_provider.dart';
import 'package:todaybread/screens/interest_area/interest_area_search_screen.dart';
import 'package:todaybread/screens/splash_screen.dart';
import 'package:todaybread/services/fcm/fcm_service.dart';
import 'package:todaybread/utils/app_colors.dart';

import 'my_page_edit_screen.dart';

/// 마이페이지 프로필 상세 화면
/// 닉네임, 이름, 휴대폰 번호 수정 진입과 계정 관리 메뉴를 제공한다.
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});
  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _notificationsEnabled = true;
  bool _isTogglingNotification = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<InterestAreaProvider>().fetch();
    });
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
                        const SizedBox(height: 20),
                        _buildInterestAreaCard(),
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
    final profileProvider = context.watch<UserProfileProvider>();

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
            value: profileProvider.nickname,
            onTap: () => _openEditScreen(
              const MyPageEditScreen(type: MyPageEditType.nickname),
            ),
            isFirst: true,
          ),
          _buildDivider(),
          _buildMenuRow(
            title: '이름',
            value: profileProvider.name,
            onTap: () => _openEditScreen(
              const MyPageEditScreen(type: MyPageEditType.name),
            ),
          ),
          _buildDivider(),
          _buildMenuRow(
            title: '휴대폰 번호 변경',
            value: profileProvider.phone,
            onTap: () => _openEditScreen(
              const MyPageEditScreen(type: MyPageEditType.phone),
            ),
          ),
          _buildDivider(),
          _buildNotificationToggleRow(),
          _buildDivider(),
          _buildMenuRow(title: '로그아웃', onTap: _showLogoutDialog),
          _buildDivider(),
          _buildMenuRow(
            title: '회원 탈퇴',
            onTap: _showWithdrawDialog,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInterestAreaCard() {
    final provider = context.watch<InterestAreaProvider>();
    final area = provider.interestArea;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Text(
              '관심지역',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFEAEAEA)),
          ),
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (area == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '관심지역이 설정되어 있지 않아요',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '키워드 알림을 받으려면 관심지역을 설정해주세요.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9C9C9C)),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => _navigateToInterestAreaSearch(
                        isCreating: true,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBackground,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '관심지역 설정',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: AppColors.primaryBackground,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          area.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          area.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '반경 ${area.radiusKm.toStringAsFixed(0)}km',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9C9C9C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _navigateToInterestAreaSearch(
                            isCreating: false,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBackground,
                            side: const BorderSide(
                              color: AppColors.primaryBackground,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('변경'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: provider.isSubmitting
                              ? null
                              : _deleteInterestArea,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE53935),
                            side: const BorderSide(color: Color(0xFFE53935)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: provider.isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFE53935),
                                  ),
                                )
                              : const Text('삭제'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _navigateToInterestAreaSearch({
    required bool isCreating,
  }) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const InterestAreaSearchScreen(),
      ),
    );
    if (!mounted || result != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCreating ? '관심지역이 설정됐어요.' : '관심지역이 변경됐어요.'),
      ),
    );
  }

  Future<void> _deleteInterestArea() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '관심지역을 삭제할까요?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          '기존 키워드는 삭제되지 않지만, 관심지역을 다시 설정하기 전까지 키워드 알림은 받을 수 없어요.',
          style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('닫기', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              '삭제',
              style: TextStyle(color: Color(0xFFE53935)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await context.read<InterestAreaProvider>().delete();
    if (!mounted) return;

    final message = result.success
        ? (result.keywordNotificationDisabled
            ? '관심지역이 삭제되어 키워드 알림이 비활성화됐어요.'
            : '관심지역이 삭제됐어요.')
        : (context.read<InterestAreaProvider>().errorMessage ??
            '삭제에 실패했습니다.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildNotificationToggleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '푸시 알림',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          _isTogglingNotification
              ? const SizedBox(
                  width: 36,
                  height: 20,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : Switch(
                  value: _notificationsEnabled,
                  onChanged: (_) => _toggleNotification(),
                  activeThumbColor: AppColors.primaryBackground,
                  activeTrackColor: AppColors.primaryBackground.withValues(alpha: 0.4),
                ),
        ],
      ),
    );
  }

  Future<void> _toggleNotification() async {
    if (_isTogglingNotification) return;
    setState(() => _isTogglingNotification = true);

    try {
      if (_notificationsEnabled) {
        // 끄기 — 서버에서 token 비활성화
        await FcmService.instance.disableToken();
        if (!mounted) return;
        setState(() => _notificationsEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('푸시 알림이 꺼졌습니다.')),
        );
      } else {
        // 켜기 — token 재발급 후 서버 재등록
        await FcmService.instance.registerTokenAfterLogin();
        if (!mounted) return;
        setState(() => _notificationsEnabled = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('푸시 알림이 켜졌습니다.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림 설정 변경에 실패했습니다. 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) setState(() => _isTogglingNotification = false);
    }
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
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _showLogoutDialog() async {
    await _showConfirmDialog(
      title: '로그아웃 전 주의사항',
      message: '현재 계정에서 로그아웃하시겠습니까?\n\n언제든 다시 로그인할 수 있습니다',
      buttonLabel: '로그 아웃',
      onConfirm: _handleLogout,
    );
  }

  Future<void> _showWithdrawDialog() async {
    await _showConfirmDialog(
      title: '회원탈퇴 전 주의사항',
      message: '회원탈퇴를 하시겠습니까?\n\n회원 탈퇴 시 모든 계정 정보와 이용 기록이 삭제되며 복구할 수 없습니다',
      buttonLabel: '회원 탈퇴',
      onConfirm: _handleWithdraw,
    );
  }

  Future<void> _showConfirmDialog({
    required String title,
    required String message,
    required String buttonLabel,
    required Future<void> Function() onConfirm,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close, color: Colors.black),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF5F5F5F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (authProvider.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFD64545),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBackground,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                buttonLabel,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<UserProfileProvider>();
    final success = await authProvider.logout();
    if (!mounted) {
      return;
    }
    if (!success) {
      return;
    }

    profileProvider.clearProfile(notify: true);
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  Future<void> _handleWithdraw() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.withdraw();
    if (!mounted) {
      return;
    }
    if (success) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    }
  }
}
