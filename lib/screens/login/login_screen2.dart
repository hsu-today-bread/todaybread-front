import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';


/// 회원가입 화면 (LoginScreen2)
///
/// - 아이디 / 비밀번호 / 닉네임 / 전화번호 입력
/// - 아이디 및 닉네임 중복 확인 기능
/// - 비밀번호 보기/숨기기 기능 제공
class LoginScreen2 extends StatefulWidget {
  const LoginScreen2({super.key});

  @override
  State<LoginScreen2> createState() => _LoginScreen2State();
}

class _LoginScreen2State extends State<LoginScreen2> {
  /// 비밀번호 표시 여부
  /// true → 비밀번호 보임
  /// false → 비밀번호 숨김
  bool _isPasswordVisible = false;
  /// 아이디 입력 컨트롤러
  final TextEditingController _idController = TextEditingController();
  /// 닉네임 입력 컨트롤러
  final TextEditingController _nicknameController = TextEditingController();

  /// 아이디 입력 여부 확인
  /// 입력값이 있을 때만 중복확인 버튼 활성화
  bool get _hasIdText => _idController.text.trim().isNotEmpty;
  /// 닉네임 입력 여부 확인
  bool get _hasNicknameText => _nicknameController.text.trim().isNotEmpty;

  @override
  void dispose() {
    /// 컨트롤러 메모리 해제
    _idController.dispose();
    _nicknameController.dispose();
    super.dispose();
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
          title: const Text(
            '회원가입',
            style: AppTextStyles.appBarTitle,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            /// 로그인스크린1로 이동
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  '아이디',
                  style: AppTextStyles.formLabel,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _idController,
                        ///이메 형태 키보드
                        keyboardType: TextInputType.emailAddress,
                        /// 자동 완성 힌트
                        autofillHints: const [AutofillHints.email],
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'ex) testID@gmail.com',
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
                            borderSide: const BorderSide(
                              color: Color(0xFFD9D9D9),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 96,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _hasIdText
                            ? () {
                                // TODO: 아이디 중복 확인
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasIdText
                              ? AppColors.primaryBackground
                              : const Color(0xFFEAEAEA),
                          foregroundColor: _hasIdText
                              ? AppColors.white
                              : const Color(0xFF8D8D8D),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '중복확인',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: AppTextStyles.duplicateCheckButton,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  '비밀번호',
                  style: AppTextStyles.formLabel,
                ),
                const SizedBox(height: 8),
                TextField(
                  /// 비밀번호 숨김 처리
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    /// 비밀번호 표시 토글 버튼
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          /// 비밀번호 표시 상태 변경
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFFD9D9D9),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '닉네임',
                  style: AppTextStyles.formLabel,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nicknameController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '닉네임을 입력해주세요',
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
                            borderSide: const BorderSide(
                              color: Color(0xFFD9D9D9),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 96,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _hasNicknameText
                            ? () {
                                // TODO: 닉네임 중복 확인
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasNicknameText
                              ? AppColors.primaryBackground
                              : const Color(0xFFEAEAEA),
                          foregroundColor: _hasNicknameText
                              ? AppColors.white
                              : const Color(0xFF8D8D8D),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '중복확인',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: AppTextStyles.duplicateCheckButton,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '* 2자~10자, 한글/영어/숫자만 사용 가능',
                  style: AppTextStyles.helperCaption,
                ),
                const SizedBox(height: 24),
                const Text(
                  '전화번호',
                  style: AppTextStyles.formLabel,
                ),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '010-1234-6789',
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
                      borderSide: const BorderSide(
                        color: Color(0xFFD9D9D9),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 회원가입 처리
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBackground,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '가입하기',
                      style: AppTextStyles.primaryAction,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
