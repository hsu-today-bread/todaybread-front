import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/boss/boss_provider.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/screens/boss/boss_store_create_screen.dart';

import '../../utils/app_colors.dart';

/// 사업자 계정 인증 화면
/// 사업자 번호, 개업일자, 대표자명을 입력받아 사장님 계정 전환을 진행한다.
class BossAccountVerificationScreen extends StatefulWidget {
  const BossAccountVerificationScreen({super.key});

  @override
  State<BossAccountVerificationScreen> createState() =>
      _BossAccountVerificationScreenState();
}

class _BossAccountVerificationScreenState
    extends State<BossAccountVerificationScreen> {
  final TextEditingController _businessNumberController =
      TextEditingController();
  final TextEditingController _businessStartDateController =
      TextEditingController();
  final TextEditingController _representativeNameController =
      TextEditingController();

  bool get _canSubmit =>
      _businessNumberController.text.trim().length == 10 &&
      _businessStartDateController.text.trim().length == 8 &&
      _representativeNameController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _businessNumberController.dispose();
    _businessStartDateController.dispose();
    _representativeNameController.dispose();
    super.dispose();
  }

  Future<void> _showMessageDialog(String message) async {
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyBusinessNumber() async {
    if (!_canSubmit) {
      await _showMessageDialog('모든 항목을 올바르게 입력해주세요.');
      return;
    }

    final bossProvider = context.read<BossProvider>();
    final authProvider = context.read<AuthProvider>();

    final response = await bossProvider.approveBoss(
      bossNumber: _businessNumberController.text.trim(),
      businessStartDate: _businessStartDateController.text.trim(),
      representativeName: _representativeNameController.text.trim(),
      authProvider: authProvider,
    );

    if (!mounted) {
      return;
    }

    if (response == null) {
      await _showMessageDialog(bossProvider.errorMessage ?? '사업자 인증에 실패했습니다.');
      return;
    }

    await _showMessageDialog(
      response.message.isEmpty
          ? '사업자 인증이 완료되었습니다. 매장 등록을 먼저 진행해주세요.'
          : '${response.message}\n매장 등록을 먼저 진행해주세요.',
    );
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const BossStoreCreateScreen(
          completionMode: StoreCreateCompletionMode.switchToBoss,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<BossProvider>().isLoading;

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
                _buildLabel('사업자 번호'),
                const SizedBox(height: 10),
                TextField(
                  controller: _businessNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration('사업자 번호 10자리를 입력해주세요'),
                ),
                const SizedBox(height: 20),
                _buildLabel('개업일자'),
                const SizedBox(height: 10),
                TextField(
                  controller: _businessStartDateController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration('개업일자 8자리를 입력해주세요 (예: 20200101)'),
                ),
                const SizedBox(height: 20),
                _buildLabel('대표자명'),
                const SizedBox(height: 10),
                TextField(
                  controller: _representativeNameController,
                  keyboardType: TextInputType.text,
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration('대표자명을 입력해주세요'),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _verifyBusinessNumber,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBackground,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
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
                        : const Text(
                            '인증하기',
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

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
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
          const Center(
            child: Text(
              '사업자 계정 인증',
              style: TextStyle(
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
