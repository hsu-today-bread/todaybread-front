import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/login/login_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/user_input_helper.dart';

/// 회원가입 화면
///
/// - 아이디 / 비밀번호 / 닉네임 / 전화번호 입력
/// - 아이디 및 닉네임 중복 확인 기능
/// - 비밀번호 보기/숨기기 기능 제공
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  /// 비밀번호 표시 여부
  /// true → 비밀번호 보임
  /// false → 비밀번호 숨김
  bool _isPasswordVisible = false;

  /// 아이디 입력 컨트롤러
  final TextEditingController _idController = TextEditingController();

  /// 닉네임 입력 컨트롤러
  final TextEditingController _nicknameController = TextEditingController();

  /// 이름 입력 컨트롤러
  final TextEditingController _nameController = TextEditingController();

  /// 비밀번호 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController();

  /// 전화번호 입력 컨트롤러
  final TextEditingController _phoneController = TextEditingController();

  /// 아이디 입력 여부 확인
  /// 입력값이 있을 때만 중복확인 버튼 활성화
  bool get _hasIdText => _idController.text.trim().isNotEmpty;

  /// 닉네임 입력 여부 확인
  bool get _hasNicknameText => _nicknameController.text.trim().isNotEmpty;

  /// 전화번호 입력 여부 확인
  bool get _hasPhoneText => _phoneController.text.trim().isNotEmpty;

  /// 닉네임 길이 유효 여부(2~10자)
  bool get _hasValidNicknameLength {
    final nickname = _nicknameController.text.trim();
    return nickname.length >= 2 && nickname.length <= 10;
  }

  @override
  void dispose() {
    /// 컨트롤러 메모리 해제
    _idController.dispose();
    _nicknameController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// 공통 스낵바 메시지를 표시합니다.
  ///
  /// [message] 사용자에게 보여줄 안내 문구입니다.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// 중복확인 결과를 팝업으로 표시합니다.
  ///
  /// [message] 팝업 본문에 노출할 안내 문구입니다.
  Future<void> _showDuplicateCheckDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: Text(message, textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryBackground,
                foregroundColor: AppColors.onPrimaryBackground,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  /// 이메일 중복 여부를 서버에서 확인합니다.
  Future<void> _checkEmailDuplicate() async {
    final authProvider = context.read<AuthProvider>();
    final exists = await authProvider.checkEmail(_idController.text.trim());
    if (!mounted) {
      return;
    }
    await _showDuplicateCheckDialog(
      authProvider.errorMessage ??
          (exists ? '이미 등록된 이메일입니다.' : '사용 가능한 이메일입니다.'),
    );
  }

  /// 닉네임 중복 여부를 서버에서 확인합니다.
  Future<void> _checkNicknameDuplicate() async {
    if (!_hasValidNicknameLength) {
      await _showDuplicateCheckDialog('닉네임은 2자~10자로 입력해주세요.');
      return;
    }
    final authProvider = context.read<AuthProvider>();
    final exists = await authProvider.checkNickname(
      _nicknameController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    await _showDuplicateCheckDialog(
      authProvider.errorMessage ??
          (exists ? '이미 사용 중인 닉네임입니다.' : '사용 가능한 닉네임입니다.'),
    );
  }

  /// 전화번호 중복 여부를 서버에서 확인합니다.
  Future<void> _checkPhoneDuplicate() async {
    final phone = _phoneController.text.trim();
    if (!UserInputHelper.isValidPhoneNumber(phone)) {
      await _showDuplicateCheckDialog('전화번호는 010-1234-5678 형식으로 입력해주세요.');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final exists = await authProvider.checkPhone(phone);
    if (!mounted) {
      return;
    }
    await _showDuplicateCheckDialog(
      authProvider.errorMessage ??
          (exists ? '이미 등록된 전화번호입니다.' : '사용 가능한 전화번호입니다.'),
    );
  }

  /// 회원가입 입력값을 검증하고 서버에 가입 요청을 전송합니다.
  Future<void> _register() async {
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();
    final nickname = _nicknameController.text.trim();
    final name = _nameController.text.trim();
    final rawPhone = _phoneController.text.trim();
    // 서버가 010-0000-0000 형식을 요구하므로 하이픈 포맷으로 변환
    final phone = rawPhone.replaceFirstMapped(
      RegExp(r'^(01[016789])(\d{3,4})(\d{4})$'),
      (m) => '${m[1]}-${m[2]}-${m[3]}',
    );

    if (id.isEmpty ||
        password.isEmpty ||
        nickname.isEmpty ||
        name.isEmpty ||
        phone.isEmpty) {
      _showMessage('입력되지 않은 항목이 있습니다. 모든 항목을 입력해주세요.');
      return;
    }
    if (nickname.length < 2 || nickname.length > 10) {
      _showMessage('닉네임은 2자~10자로 입력해주세요.');
      return;
    }
    if (!UserInputHelper.isValidEmail(id)) {
      _showMessage('올바른 이메일 형식으로 입력해주세요.');
      return;
    }
    if (password.length < UserInputHelper.minPasswordLength) {
      _showMessage('비밀번호는 최소 10자 이상 입력해주세요.');
      return;
    }
    if (!UserInputHelper.isValidPhoneNumber(phone)) {
      _showMessage('전화번호는 010-1234-5678 형식으로 입력해주세요.');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: id,
      nickname: nickname,
      name: name,
      password: password,
      phone: phone,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pop(context, '회원가입이 완료되었습니다.');
      return;
    }

    _showMessage(authProvider.errorMessage ?? '회원가입에 실패했습니다.');
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<AuthProvider>().isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryBackground,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('회원가입', style: AppTextStyles.appBarTitle),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.onPrimaryBackground,
            ),

            /// 로그인스크린1로 이동
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBackground,
                  foregroundColor: AppColors.onPrimaryBackground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                    : const Text('가입하기', style: AppTextStyles.primaryAction),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text('이메일', style: AppTextStyles.formLabel),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _idController,
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
                        onPressed: _hasIdText && !isSubmitting
                            ? _checkEmailDuplicate
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasIdText
                              ? AppColors.primaryBackground
                              : const Color(0xFFEAEAEA),
                          foregroundColor: _hasIdText
                              ? AppColors.onPrimaryBackground
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
                const Text('비밀번호', style: AppTextStyles.formLabel),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,

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
                      borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '* 최소 10자 이상 입력해주세요.',
                  style: AppTextStyles.helperCaption,
                ),
                const SizedBox(height: 24),
                const Text('닉네임', style: AppTextStyles.formLabel),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nicknameController,
                        inputFormatters: [LengthLimitingTextInputFormatter(10)],
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
                        onPressed: _hasNicknameText && !isSubmitting
                            ? _checkNicknameDuplicate
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasNicknameText
                              ? AppColors.primaryBackground
                              : const Color(0xFFEAEAEA),
                          foregroundColor: _hasNicknameText
                              ? AppColors.onPrimaryBackground
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
                const Text('이름', style: AppTextStyles.formLabel),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: '이름을 입력해주세요',
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: const [
                          PhoneNumberTextInputFormatter(),
                        ],
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '010-1234-5678',
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
                        onPressed: _hasPhoneText && !isSubmitting
                            ? _checkPhoneDuplicate
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasPhoneText
                              ? AppColors.primaryBackground
                              : const Color(0xFFEAEAEA),
                          foregroundColor: _hasPhoneText
                              ? AppColors.onPrimaryBackground
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
                  '* 010-1234-5678 형식으로 입력해주세요.',
                  style: AppTextStyles.helperCaption,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
