import 'package:flutter/material.dart';
import 'package:todaybread/models/store/business_hours_request.dart';
import 'package:todaybread/utils/app_colors.dart';
import 'package:todaybread/utils/business_hours_helper.dart';

class BusinessHoursEditor extends StatelessWidget {
  final BusinessHoursRequest template;
  final List<BusinessHoursRequest> businessHours;
  final ValueChanged<BusinessHoursRequest> onTemplateChanged;
  final VoidCallback onApplyTemplateToAll;
  final VoidCallback onApplyTemplateToWeekdays;
  final VoidCallback onApplyTemplateToWeekend;
  final ValueChanged<BusinessHoursRequest> onDayChanged;

  const BusinessHoursEditor({
    super.key,
    required this.template,
    required this.businessHours,
    required this.onTemplateChanged,
    required this.onApplyTemplateToAll,
    required this.onApplyTemplateToWeekdays,
    required this.onApplyTemplateToWeekend,
    required this.onDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TemplateCard(
          template: template,
          onChanged: onTemplateChanged,
          onApplyTemplateToAll: onApplyTemplateToAll,
          onApplyTemplateToWeekdays: onApplyTemplateToWeekdays,
          onApplyTemplateToWeekend: onApplyTemplateToWeekend,
        ),
        const SizedBox(height: 18),
        ...businessHours.map(
          (value) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _BusinessHoursDayCard(value: value, onChanged: onDayChanged),
          ),
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final BusinessHoursRequest template;
  final ValueChanged<BusinessHoursRequest> onChanged;
  final VoidCallback onApplyTemplateToAll;
  final VoidCallback onApplyTemplateToWeekdays;
  final VoidCallback onApplyTemplateToWeekend;

  const _TemplateCard({
    required this.template,
    required this.onChanged,
    required this.onApplyTemplateToAll,
    required this.onApplyTemplateToWeekdays,
    required this.onApplyTemplateToWeekend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E4E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '공통 시간 설정',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '한 번 입력한 뒤 모든 요일, 평일, 주말에 바로 복사할 수 있습니다.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Color(0xFF7C7C7C),
            ),
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            value: template.isClosed,
            onChanged: (value) {
              onChanged(
                template.copyWith(
                  isClosed: value,
                  startTime: value
                      ? null
                      : template.startTime ?? defaultBusinessStartTime,
                  endTime: value
                      ? null
                      : template.endTime ?? defaultBusinessEndTime,
                  lastOrderTime: value
                      ? null
                      : template.lastOrderTime ?? defaultBusinessLastOrderTime,
                ),
              );
            },
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primaryBackground,
            title: const Text(
              '휴무로 설정',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          if (!template.isClosed) ...[
            _TimeRow(
              title: '시작',
              value: template.startTime,
              onChanged: (value) {
                onChanged(template.copyWith(startTime: value));
              },
            ),
            const SizedBox(height: 10),
            _TimeRow(
              title: '종료',
              value: template.endTime,
              onChanged: (value) {
                onChanged(template.copyWith(endTime: value));
              },
            ),
            const SizedBox(height: 10),
            _TimeRow(
              title: '라스트오더',
              value: template.lastOrderTime,
              onChanged: (value) {
                onChanged(template.copyWith(lastOrderTime: value));
              },
            ),
            const SizedBox(height: 14),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ApplyButton(label: '모든 요일', onTap: onApplyTemplateToAll),
              _ApplyButton(label: '평일 적용', onTap: onApplyTemplateToWeekdays),
              _ApplyButton(label: '주말 적용', onTap: onApplyTemplateToWeekend),
            ],
          ),
        ],
      ),
    );
  }
}

class _BusinessHoursDayCard extends StatelessWidget {
  final BusinessHoursRequest value;
  final ValueChanged<BusinessHoursRequest> onChanged;

  const _BusinessHoursDayCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _showEditor(context),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E4E4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weekdayLabel(value.dayOfWeek)}요일',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      buildBusinessHoursSummary(
                        isClosed: value.isClosed,
                        startTime: value.startTime,
                        endTime: value.endTime,
                        lastOrderTime: value.lastOrderTime,
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Color(0xFF5E5E5E),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: value.isClosed
                      ? const Color(0xFFF3E2E2)
                      : const Color(0xFFE5F3EF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  value.isClosed ? '휴무' : '수정',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: value.isClosed
                        ? const Color(0xFFA14A4A)
                        : AppColors.primaryBackground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditor(BuildContext context) async {
    bool isClosed = value.isClosed;
    String? startTime = value.startTime;
    String? endTime = value.endTime;
    String? lastOrderTime = value.lastOrderTime;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  20 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weekdayLabel(value.dayOfWeek)}요일 영업시간',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      value: isClosed,
                      onChanged: (closed) {
                        setModalState(() {
                          isClosed = closed;
                          if (closed) {
                            startTime = null;
                            endTime = null;
                            lastOrderTime = null;
                          } else {
                            startTime ??= defaultBusinessStartTime;
                            endTime ??= defaultBusinessEndTime;
                            lastOrderTime ??= defaultBusinessLastOrderTime;
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppColors.primaryBackground,
                      title: const Text(
                        '휴무로 설정',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (!isClosed) ...[
                      _TimeRow(
                        title: '시작',
                        value: startTime,
                        onChanged: (selected) {
                          setModalState(() {
                            startTime = selected;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _TimeRow(
                        title: '종료',
                        value: endTime,
                        onChanged: (selected) {
                          setModalState(() {
                            endTime = selected;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _TimeRow(
                        title: '라스트오더',
                        value: lastOrderTime,
                        onChanged: (selected) {
                          setModalState(() {
                            lastOrderTime = selected;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          final error = validateBusinessHoursValues(
                            isClosed: isClosed,
                            startTime: startTime,
                            endTime: endTime,
                            lastOrderTime: lastOrderTime,
                            label: '${weekdayLabel(value.dayOfWeek)}요일',
                          );
                          if (error != null) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(error)));
                            return;
                          }

                          onChanged(
                            value.copyWith(
                              isClosed: isClosed,
                              startTime: isClosed ? null : startTime,
                              endTime: isClosed ? null : endTime,
                              lastOrderTime: isClosed ? null : lastOrderTime,
                            ),
                          );
                          Navigator.of(bottomSheetContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBackground,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '적용하기',
                          style: TextStyle(
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
}

class _TimeRow extends StatelessWidget {
  final String title;
  final String? value;
  final ValueChanged<String> onChanged;

  const _TimeRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 86,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () async {
              final initial =
                  parseBusinessTime(value) ??
                  const TimeOfDay(hour: 9, minute: 0);
              final picked = await showTimePicker(
                context: context,
                initialTime: initial,
              );
              if (picked == null) {
                return;
              }
              onChanged(timeOfDayToBusinessString(picked));
            },
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD9D9D9)),
              ),
              child: Text(
                formatBusinessTime(value),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ApplyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ApplyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primaryBackground),
        foregroundColor: AppColors.primaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}
