import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../providers/user/user_profile_provider.dart';
import '../../services/local/user_local_store.dart';
import '../../utils/app_colors.dart';

enum MyPageEditType { nickname, name, phone }

class MyPageEditScreen extends StatefulWidget {
  const MyPageEditScreen({super.key, required this.type});

  final MyPageEditType type;

  @override
  State<MyPageEditScreen> createState() => _MyPageEditScreenState();
}

class _MyPageEditScreenState extends State<MyPageEditScreen> {
  late final TextEditingController _controller;
  final UserProfileProvider _profileProvider = UserProfileProvider();
  bool _isSaving = false;

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

  String get _initialValue {
    switch (widget.type) {
      case MyPageEditType.nickname:
        return UserLocalStore.getNickname();
      case MyPageEditType.name:
        return UserLocalStore.getName();
      case MyPageEditType.phone:
        return UserLocalStore.getPhone();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    _profileProvider.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (value.isEmpty || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final nickname = widget.type == MyPageEditType.nickname
        ? value
        : UserLocalStore.getNickname();
    final name = widget.type == MyPageEditType.name
        ? value
        : UserLocalStore.getName();
    final phone = widget.type == MyPageEditType.phone
        ? value
        : UserLocalStore.getPhone();

    await UserLocalStore.saveUser(nickname: nickname, name: name, phone: phone);

    if (!mounted) {
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

        final exists = await _profileProvider.checkNickname(value);
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
        final exists = await _profileProvider.checkPhone(value);
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
                            ? [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ]
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
