import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  void dispose() {
    _findIdPhoneController.dispose();
    _findPasswordIdController.dispose();
    _findPasswordPhoneController.dispose();
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
          title: const Text('아이디/비밀번호 찾기', style: AppTextStyles.appBarTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),

            /// 이전 화면(LoginScreen)으로 이동
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 전화번호 라벨 (아이디 찾기)
                  const Text('전화번호', style: AppTextStyles.formLabel),
                  const SizedBox(height: 8),

                  /// 아이디 찾기용 전화번호 입력 필드
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

                  const SizedBox(height: 28),

                  /// 아이디 찾기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: 아이디 찾기 API 연결
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
                        '이메일 찾기',
                        style: AppTextStyles.primaryAction,
                      ),
                    ),
                  ),

                  const SizedBox(height: 44),

                  /// 아이디 라벨 (비밀번호 찾기)
                  const Text('이메일', style: AppTextStyles.formLabel),
                  const SizedBox(height: 8),

                  /// 비밀번호 찾기용 아이디 입력 필드
                  TextField(
                    controller: _findPasswordIdController,
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

                  /// 전화번호 라벨 (비밀번호 찾기)
                  const Text('전화번호', style: AppTextStyles.formLabel),
                  const SizedBox(height: 8),

                  /// 비밀번호 찾기용 전화번호 입력 필드
                  TextField(
                    controller: _findPasswordPhoneController,
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

                  const SizedBox(height: 28),

                  /// 비밀번호 찾기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: 비밀번호 찾기 API 연결
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
                        '비밀번호 찾기',
                        style: AppTextStyles.primaryAction,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
