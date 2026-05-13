import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/main/main_tab_provider.dart';
import 'package:todaybread/utils/app_colors.dart';

enum _ResultType { success, fail }

/// 결제 결과 화면 (성공 / 실패)
class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen._({
    required _ResultType type,
    this.orderId,
    this.paymentKey,
    this.amount,
    this.storeName,
    this.errorCode,
    this.errorMessage,
  }) : _type = type;

  /// 결제 성공 화면
  factory PaymentResultScreen.success({
    String? orderId,
    String? paymentKey,
    int? amount,
    String? storeName,
  }) => PaymentResultScreen._(
    type: _ResultType.success,
    orderId: orderId,
    paymentKey: paymentKey,
    amount: amount,
    storeName: storeName,
  );

  /// 결제 실패 화면
  factory PaymentResultScreen.fail({
    String? orderId,
    String? errorCode,
    String? errorMessage,
  }) => PaymentResultScreen._(
    type: _ResultType.fail,
    orderId: orderId,
    errorCode: errorCode,
    errorMessage: errorMessage,
  );

  final _ResultType _type;
  final String? orderId;
  final String? paymentKey;
  final int? amount;
  final String? storeName;
  final String? errorCode;
  final String? errorMessage;

  bool get _isSuccess => _type == _ResultType.success;
  static const int _userMyPageTabIndex = 3;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildIcon(),
                const SizedBox(height: 28),
                _buildTitle(),
                const SizedBox(height: 12),
                _buildSubtitle(),
                const SizedBox(height: 36),
                if (_isSuccess) _buildSuccessDetails(),
                const Spacer(flex: 3),
                _buildButtons(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: _isSuccess
            ? AppColors.primaryBackground.withValues(alpha: 0.12)
            : const Color(0xFFFFEEEE),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
        size: 56,
        color: _isSuccess
            ? AppColors.primaryBackground
            : const Color(0xFFE53935),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      _isSuccess ? '결제 완료' : '결제 실패',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: _isSuccess ? Colors.black : const Color(0xFFE53935),
      ),
    );
  }

  Widget _buildSubtitle() {
    final text = _isSuccess
        ? '주문이 완료되었습니다.\n가게에서 픽업해 주세요!'
        : _buildFailMessage();
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black54),
    );
  }

  String _buildFailMessage() {
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return errorMessage!;
    }
    return '결제를 처리하는 중 문제가 발생했습니다.\n다시 시도해 주세요.';
  }

  Widget _buildSuccessDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (storeName != null) ...[
            _DetailRow(label: '가게', value: storeName!),
            const SizedBox(height: 12),
          ],
          if (orderId != null) ...[
            _DetailRow(label: '주문번호', value: orderId!),
            const SizedBox(height: 12),
          ],
          if (amount != null)
            _DetailRow(
              label: '결제 금액',
              value: '${_formatPrice(amount!)}원',
              valueStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    if (_isSuccess) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => _goOrderHistory(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBackground,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '주문내역 보기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () => _goHome(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black54,
                side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '홈으로 가기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBackground,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '다시 시도',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: () => _goHome(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black54,
              side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '취소하고 홈으로',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _goOrderHistory(BuildContext context) {
    context.read<MainTabProvider>().requestTab(_userMyPageTabIndex);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black45),
        ),
        const Spacer(),
        Text(
          value,
          style:
              valueStyle ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
        ),
      ],
    );
  }
}
