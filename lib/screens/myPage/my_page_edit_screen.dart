import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/user/user_profile_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/user_input_helper.dart';

enum MyPageEditType { nickname, name, phone }

/// 마이페이지 공통 정보 수정 화면
/// 닉네임, 이름, 휴대폰 번호 수정을 타입별로 처리한다.
class MyPageEditScreen extends StatefulWidget {
  const MyPageEditScreen({super.key, required this.type});

  final MyPageEditType type;

  @override
  State<MyPageEditScreen> createState() => _MyPageEditScreenState();
}

class _MyPageEditScreenState extends State<MyPageEditScreen> {
  late final TextEditingController _controller;
  bool _isSaving = false;
  bool _didInitController = false;

  String get _title {
    switch (widget.type) {
      case MyPageEditType.nickname:
        return '닉네임 변경';
      case MyPageEditType.name:
        return '이름 변경';
      case MyPageEditType.phone:
        return '휴대폰 번호 변경';
    }
  }

  String get _label {
    switch (widget.type) {
      case MyPageEditType.nickname:
        return '닉네임';
      case MyPageEditType.name:
        return '이름';
      case MyPageEditType.phone:
        return '휴대폰 번호';
    }
  }

  String get _hint {
    switch (widget.type) {
      case MyPageEditType.nickname:
        return '닉네임을 입력해주세요';
      case MyPageEditType.name:
        return '이름을 입력해주세요';
      case MyPageEditType.phone:
        return '휴대폰 번호를 입력해주세요';
    }
  }

  String _initialValue(UserProfileProvider profileProvider) {
    switch (widget.type) {
      case MyPageEditType.nickname:
        return profileProvider.nickname;
      case MyPageEditType.name:
        return profileProvider.name;
      case MyPageEditType.phone:
        return profileProvider.phone;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitController) {
      return;
    }
    final profileProvider = context.read<UserProfileProvider>();
    final initialValue = _initialValue(profileProvider);
    _controller = TextEditingController(
      text: widget.type == MyPageEditType.phone
          ? UserInputHelper.normalizePhoneNumber(initialValue)
          : initialValue,
    );
    _didInitController = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (value.isEmpty || _isSaving) {
      return;
    }

    if (widget.type == MyPageEditType.nickname &&
        (value.length < 2 || value.length > 10)) {
      await _showDuplicateCheckDialog('닉네임은 2자~10자로 입력해주세요.');
      return;
    }
    if (widget.type == MyPageEditType.phone &&
        !UserInputHelper.isValidPhoneNumber(value)) {
      await _showDuplicateCheckDialog('전화번호는 010-1234-5678 형식으로 입력해주세요.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final nickname = widget.type == MyPageEditType.nickname
        ? value
        : context.read<UserProfileProvider>().nickname;
    final name = widget.type == MyPageEditType.name
        ? value
        : context.read<UserProfileProvider>().name;
    final phone = widget.type == MyPageEditType.phone
        ? UserInputHelper.normalizePhoneNumber(value)
        : UserInputHelper.normalizePhoneNumber(
            context.read<UserProfileProvider>().phone,
          );

    if (!mounted) {
      return;
    }

    final profileProvider = context.read<UserProfileProvider>();
    final response = await profileProvider.updateProfile(
      nickname: nickname,
      name: name,
      phone: phone,
    );

    if (!mounted) {
      return;
    }

    if (response == null) {
      setState(() {
        _isSaving = false;
      });
      await _showDuplicateCheckDialog(
        profileProvider.errorMessage ?? '정보 수정에 실패했습니다.',
      );
      return;
    }

    setState(() {
      _isSaving = false;
    });
    Navigator.pop(context, true);
  }

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
                foregroundColor: AppColors.white,
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

  Future<void> _checkDuplicate() async {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      await _showDuplicateCheckDialog('$_label을 입력해주세요.');
      return;
    }

    switch (widget.type) {
      case MyPageEditType.nickname:
        if (value.length < 2 || value.length > 10) {
          await _showDuplicateCheckDialog('닉네임은 2자~10자로 입력해주세요.');
          return;
        }

        final exists = await context.read<UserProfileProvider>().checkNickname(
          value,
        );
        if (!mounted) {
          return;
        }
        await _showDuplicateCheckDialog(
          exists ? '이미 사용 중인 닉네임입니다.' : '사용 가능한 닉네임입니다.',
        );
        return;
      case MyPageEditType.name:
        await _showDuplicateCheckDialog('사용 가능한 이름입니다.');
        return;
      case MyPageEditType.phone:
        if (!UserInputHelper.isValidPhoneNumber(value)) {
          await _showDuplicateCheckDialog('전화번호는 010-1234-5678 형식으로 입력해주세요.');
          return;
        }

        final exists = await context.read<UserProfileProvider>().checkPhone(
          UserInputHelper.normalizePhoneNumber(value),
        );
        if (!mounted) {
          return;
        }
        await _showDuplicateCheckDialog(
          exists ? '이미 등록된 전화번호입니다.' : '사용 가능한 전화번호입니다.',
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF7F7F7),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              children: [
                _buildAppBar(context),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        keyboardType: widget.type == MyPageEditType.phone
                            ? TextInputType.phone
                            : TextInputType.text,
                        inputFormatters: widget.type == MyPageEditType.phone
                            ? const [PhoneNumberTextInputFormatter()]
                            : [],
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: _hint,
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD9D9D9),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 96,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: hasText ? _checkDuplicate : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasText
                              ? AppColors.primaryBackground
                              : const Color(0xFFEAEAEA),
                          foregroundColor: hasText
                              ? Colors.white
                              : const Color(0xFF8D8D8D),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '중복확인',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: hasText && !_isSaving ? _save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBackground,
                      disabledBackgroundColor: const Color(0xFFEAEAEA),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: const Color(0xFF8D8D8D),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            '확인',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SizedBox(
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
          Center(
            child: Text(
              _title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
