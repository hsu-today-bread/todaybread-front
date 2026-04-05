import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/users/reset_password_request.dart';
import '../../services/login/login_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

/// 아이디 / 비밀번호 찾기 화면
///
/// - 전화번호로 아이디 찾기
/// - 아이디 + 전화번호로 비밀번호 찾기
class AccountRecoveryScreen extends StatefulWidget {
  const AccountRecoveryScreen({super.key});

  @override
  State<AccountRecoveryScreen> createState() => _AccountRecoveryScreenState();
}

class _AccountRecoveryScreenState extends State<AccountRecoveryScreen> {
  /// 아이디 찾기용 전화번호 입력 컨트롤러
  final TextEditingController _findIdPhoneController = TextEditingController();

  /// 비밀번호 찾기용 아이디 입력 컨트롤러
  final TextEditingController _findPasswordIdController =
      TextEditingController();

  /// 비밀번호 찾기용 전화번호 입력 컨트롤러
  final TextEditingController _findPasswordPhoneController =
      TextEditingController();

  /// 새 비밀번호 입력 컨트롤러
  final TextEditingController _newPasswordController = TextEditingController();

  /// 이메일 찾기 결과 (마스킹된 이메일)
  String? _foundEmail;

  /// 본인인증 완료 여부
  bool _identityVerified = false;

  /// 본인인증 후 서버로부터 받은 이메일 (비밀번호 재설정에 사용)
  String? _verifiedEmail;

  bool _isFindingEmail = false;
  bool _isVerifying = false;
  bool _isResettingPassword = false;

  @override
  void dispose() {
    _findIdPhoneController.dispose();
    _findPasswordIdController.dispose();
    _findPasswordPhoneController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _findEmail() async {
    final phone = _findIdPhoneController.text.trim();
    if (phone.isEmpty) {
      _showSnackBar('전화번호를 입력해주세요.');
      return;
    }
    setState(() => _isFindingEmail = true);
    try {
      final response = await LoginService.instance.findEmail(phone);
      setState(() => _foundEmail = response.maskedEmail);
    } catch (e) {
      _showSnackBar('가입 정보를 찾을 수 없습니다.');
    } finally {
      setState(() => _isFindingEmail = false);
    }
  }

  Future<void> _verifyIdentity() async {
    final email = _findPasswordIdController.text.trim();
    final phone = _findPasswordPhoneController.text.trim();
    if (email.isEmpty || phone.isEmpty) {
      _showSnackBar('이메일과 전화번호를 모두 입력해주세요.');
      return;
    }
    setState(() => _isVerifying = true);
    try {
      final response =
          await LoginService.instance.verifyIdentity(phone, email);
      if (response.verified) {
        setState(() {
          _identityVerified = true;
          _verifiedEmail = response.email;
        });
      } else {
        _showSnackBar('가입 정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      _showSnackBar('가입 정보를 찾을 수 없습니다.');
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    if (newPassword.isEmpty) {
      _showSnackBar('새 비밀번호를 입력해주세요.');
      return;
    }
    setState(() => _isResettingPassword = true);
    try {
      final response = await LoginService.instance.resetPassword(
        ResetPasswordRequest(
          email: _verifiedEmail!,
          newPassword: newPassword,
        ),
      );
      if (response.success) {
        _showSnackBar('비밀번호가 재설정되었습니다.');
        if (mounted) Navigator.pop(context);
      } else {
        _showSnackBar(response.message);
      }
    } catch (e) {
      _showSnackBar('비밀번호 재설정에 실패했습니다.');
    } finally {
      setState(() => _isResettingPassword = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryBackground,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('아이디/비밀번호 찾기', style: AppTextStyles.appBarTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ── 이메일 찾기 섹션 ──────────────────────────────
                  const Text('전화번호', style: AppTextStyles.formLabel),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _findIdPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '전화번호를 입력해주세요',
                      hintStyle: AppTextStyles.formHint,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  if (_foundEmail != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '찾은 이메일: $_foundEmail',
                        style: AppTextStyles.formLabel,
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isFindingEmail ? null : _findEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBackground,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isFindingEmail
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              '이메일 찾기',
                              style: AppTextStyles.primaryAction,
                            ),
                    ),
                  ),

                  const SizedBox(height: 44),

                  /// ── 비밀번호 찾기 섹션 ────────────────────────────
                  const Text('이메일', style: AppTextStyles.formLabel),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _findPasswordIdController,
                    enabled: !_identityVerified,
                    decoration: InputDecoration(
                      hintText: '아이디를 입력해주세요',
                      hintStyle: AppTextStyles.formHint,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text('전화번호', style: AppTextStyles.formLabel),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _findPasswordPhoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !_identityVerified,
                    decoration: InputDecoration(
                      hintText: '전화번호를 입력해주세요',
                      hintStyle: AppTextStyles.formHint,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  if (!_identityVerified)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isVerifying ? null : _verifyIdentity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBackground,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isVerifying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                '비밀번호 찾기',
                                style: AppTextStyles.primaryAction,
                              ),
                      ),
                    ),

                  /// 본인인증 완료 후 새 비밀번호 입력 섹션
                  if (_identityVerified) ...[
                    const Text('새 비밀번호', style: AppTextStyles.formLabel),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '새 비밀번호를 입력해주세요',
                        hintStyle: AppTextStyles.formHint,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFFD9D9D9)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed:
                            _isResettingPassword ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBackground,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isResettingPassword
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                '비밀번호 재설정',
                                style: AppTextStyles.primaryAction,
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
