import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/models/boss/boss_sales_response.dart';
import 'package:todaybread/providers/boss/boss_sales_provider.dart';
import 'package:todaybread/utils/app_colors.dart';

class BossSalesScreen extends StatefulWidget {
  const BossSalesScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<BossSalesScreen> createState() => _BossSalesScreenState();
}

class _BossSalesScreenState extends State<BossSalesScreen> {
  late DateTime _visibleMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final today = _normalizeDate(DateTime.now());
    _visibleMonth = DateTime(today.year, today.month);
    _selectedDate = today;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BossSalesProvider>().fetchMonthlySales(_visibleMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = context.watch<BossSalesProvider>();
    final monthlyResponse = salesProvider.monthlySalesFor(_visibleMonth);
    final monthlyRows =
        monthlyResponse?.menuSummaries ?? const <BossSalesMenuSummary>[];
    final monthlyQuantity = monthlyResponse?.totalQuantity ?? 0;
    final monthlyAmount = monthlyResponse?.totalAmount ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: widget.showAppBar
          ? AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: const Color(0xFFF7F7F7),
              surfaceTintColor: const Color(0xFFF7F7F7),
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              centerTitle: true,
              title: const Text(
                '매출관리',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            )
          : null,
      body: SafeArea(
        top: !widget.showAppBar,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, widget.showAppBar ? 12 : 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.showAppBar) ...[
                const Text(
                  '매출관리',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '달력에서 날짜를 눌러 일별 매출을 확인하세요.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF767676)),
                ),
                const SizedBox(height: 10),
              ],
              _buildSalesLegend(),
              const SizedBox(height: 18),
              _buildCalendarCard(salesProvider, monthlyResponse),
              if (salesProvider.errorMessage != null && monthlyResponse == null)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    salesProvider.errorMessage!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD2554C),
                    ),
                  ),
                ),
              const SizedBox(height: 22),
              _SalesSummaryCard(
                title: '${_visibleMonth.month}월 월별 매출 조회',
                rows: monthlyRows,
                totalQuantity: monthlyQuantity,
                totalAmount: monthlyAmount,
                isLoading:
                    salesProvider.isMonthlyLoading && monthlyResponse == null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesLegend() {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: const [
        _SalesLegendItem(color: Color(0xFF39B86C), label: '판매 기록 있음'),
        _SalesLegendItem(color: Color(0xFFE06262), label: '판매 기록 없음'),
      ],
    );
  }

  Widget _buildCalendarCard(
    BossSalesProvider salesProvider,
    BossMonthlySalesResponse? monthlyResponse,
  ) {
    final monthDays = _buildCalendarDays(_visibleMonth);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _moveMonth(-1),
                icon: const Icon(Icons.chevron_left_rounded, size: 24),
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _showYearPicker,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_visibleMonth.year}년',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 22,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_visibleMonth.month}월',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _canMoveToNextMonth ? () => _moveMonth(1) : null,
                icon: Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: _canMoveToNextMonth
                      ? Colors.black
                      : const Color(0xFFC8C8C8),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (salesProvider.isMonthlyLoading && monthlyResponse == null) ...[
            const SizedBox(height: 6),
            const LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.primaryBackground,
              backgroundColor: Color(0xFFE8E8E8),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: _weekdayLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: label == '일'
                              ? const Color(0xFFE35D4F)
                              : label == '토'
                              ? const Color(0xFF4A79E0)
                              : const Color(0xFF6F6F6F),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: monthDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 72,
            ),
            itemBuilder: (context, index) {
              final date = monthDays[index];
              if (date == null) {
                return const SizedBox.shrink();
              }
              final normalized = _normalizeDate(date);
              final amount = salesProvider.amountForDate(normalized);
              final hasSales = salesProvider.hasSalesOn(normalized);
              final isSelected =
                  _selectedDate != null &&
                  _normalizeDate(_selectedDate!) == normalized;
              final isToday = normalized == _normalizeDate(DateTime.now());

              return InkWell(
                onTap: () => _handleDateTap(normalized),
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFF4D8)
                        : hasSales
                        ? const Color(0xFFF7FCF8)
                        : const Color(0xFFFFF7F7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isToday
                          ? AppColors.primaryBackground
                          : isSelected
                          ? const Color(0xFFE8D69C)
                          : hasSales
                          ? const Color(0xFFDCEFE2)
                          : const Color(0xFFF0DDDD),
                      width: isToday ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? const Color(0xFF604800)
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              amount > 0 ? _formatCompactPrice(amount) : '0원',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: hasSales
                                    ? const Color(0xFF2F2F2F)
                                    : const Color(0xFF9A9A9A),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: hasSales
                                ? const Color(0xFF39B86C)
                                : const Color(0xFFE06262),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleDateTap(DateTime date) async {
    setState(() {
      _selectedDate = date;
    });

    final response = await context.read<BossSalesProvider>().fetchDailySales(
      date,
    );
    if (!mounted) {
      return;
    }

    if (response == null) {
      final message =
          context.read<BossSalesProvider>().errorMessage ?? '매출 조회에 실패했습니다.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    await _showDailySalesSheet(date);
  }

  Future<void> _showDailySalesSheet(DateTime date) async {
    final response = context.read<BossSalesProvider>().dailySalesFor(date);
    final rows = response?.menuSummaries ?? const <BossSalesMenuSummary>[];
    final totalQuantity = response?.totalQuantity ?? 0;
    final totalAmount = response?.totalAmount ?? 0;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F7F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD3D3D3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${date.month}월 ${date.day}일 일별 매출 조회',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rows.isEmpty ? '선택한 날짜의 매출이 없습니다.' : '선택한 날짜의 판매 내역입니다.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF777777),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SalesSummaryCard(
                    title: null,
                    rows: rows,
                    totalQuantity: totalQuantity,
                    totalAmount: totalAmount,
                    isLoading: false,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _moveMonth(int offset) {
    final nextMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + offset,
    );
    if (offset > 0 && nextMonth.isAfter(_currentMonth)) {
      return;
    }
    setState(() {
      _visibleMonth = nextMonth;
      _selectedDate = null;
    });
    context.read<BossSalesProvider>().fetchMonthlySales(_visibleMonth);
  }

  Future<void> _showYearPicker() async {
    final currentYear = DateTime.now().year;
    final years = List<int>.generate(6, (index) => currentYear - index);
    final selectedYear = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '연도 선택',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 14),
                for (final year in years)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '$year년',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: year == _visibleMonth.year
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    trailing: year == _visibleMonth.year
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primaryBackground,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(year),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedYear == null || !mounted) {
      return;
    }

    final currentMonth = DateTime.now().month;
    final clampedMonth = selectedYear == currentYear
        ? _visibleMonth.month.clamp(1, currentMonth)
        : _visibleMonth.month;

    setState(() {
      _visibleMonth = DateTime(selectedYear, clampedMonth);
      _selectedDate = null;
    });
    context.read<BossSalesProvider>().fetchMonthlySales(_visibleMonth);
  }

  List<DateTime?> _buildCalendarDays(DateTime visibleMonth) {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final lastDay = DateTime(visibleMonth.year, visibleMonth.month + 1, 0);
    final leadingEmptyCount = firstDay.weekday % 7;
    final totalDayCount = leadingEmptyCount + lastDay.day;
    final trailingEmptyCount = (7 - totalDayCount % 7) % 7;

    return [
      ...List<DateTime?>.filled(leadingEmptyCount, null),
      ...List<DateTime?>.generate(
        lastDay.day,
        (index) => DateTime(visibleMonth.year, visibleMonth.month, index + 1),
      ),
      ...List<DateTime?>.filled(trailingEmptyCount, null),
    ];
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime get _currentMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  bool get _canMoveToNextMonth => _visibleMonth.isBefore(_currentMonth);

  static String _formatCompactPrice(int price) {
    if (price >= 10000) {
      final value = price / 10000;
      final text = value % 1 == 0
          ? value.toInt().toString()
          : value.toStringAsFixed(1);
      return '$text만원';
    }
    if (price >= 1000) {
      final value = price / 1000;
      final text = value % 1 == 0
          ? value.toInt().toString()
          : value.toStringAsFixed(1);
      return '$text천원';
    }
    return '$price원';
  }

  static String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

class _SalesLegendItem extends StatelessWidget {
  const _SalesLegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6F6F6F),
          ),
        ),
      ],
    );
  }
}

class _SalesSummaryCard extends StatelessWidget {
  const _SalesSummaryCard({
    required this.title,
    required this.rows,
    required this.totalQuantity,
    required this.totalAmount,
    required this.isLoading,
  });

  final String? title;
  final List<BossSalesMenuSummary> rows;
  final int totalQuantity;
  final int totalAmount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 18),
          ],
          const _SalesHeaderRow(),
          const SizedBox(height: 10),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                '매출 데이터가 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7C7C7C),
                ),
              ),
            )
          else
            for (int index = 0; index < rows.length; index++) ...[
              _SalesDataRow(item: rows[index]),
              if (index != rows.length - 1)
                const Divider(
                  height: 20,
                  thickness: 1,
                  color: Color(0xFFE8E8E8),
                ),
            ],
          const Divider(height: 28, thickness: 1.2, color: Color(0xFFD7D7D7)),
          _SalesTotalRow(
            totalQuantity: totalQuantity,
            totalAmount: totalAmount,
          ),
        ],
      ),
    );
  }
}

class _SalesHeaderRow extends StatelessWidget {
  const _SalesHeaderRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            '메뉴',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8A8A8A),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '수량',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8A8A8A),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            '가격',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8A8A8A),
            ),
          ),
        ),
      ],
    );
  }
}

class _SalesDataRow extends StatelessWidget {
  const _SalesDataRow({required this.item});

  final BossSalesMenuSummary item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              item.menuName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${item.quantity}개',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4E4E4E),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${_BossSalesScreenState._formatPrice(item.amount)}원',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2F2F2F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesTotalRow extends StatelessWidget {
  const _SalesTotalRow({
    required this.totalQuantity,
    required this.totalAmount,
  });

  final int totalQuantity;
  final int totalAmount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 5,
          child: Text(
            '총 판매내역',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '$totalQuantity개',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            '${_BossSalesScreenState._formatPrice(totalAmount)}원',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

const List<String> _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];
