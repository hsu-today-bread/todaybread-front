import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/models/bread/bread_common_response.dart';
import 'package:todaybread/providers/boss/boss_bread_create_provider.dart';
import 'package:todaybread/providers/bread/bread_provider.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/utils/app_colors.dart';
import 'package:todaybread/widgets/app_network_image.dart';

/// 사장님 메뉴 등록 화면입니다.
///
/// step 단위 입력값은 로컬 provider에 보관하고,
/// 마지막 완료 시점에만 BreadProvider를 통해 API를 호출합니다.
class BossBreadCreateScreen extends StatelessWidget {
  const BossBreadCreateScreen({
    super.key,
    this.initialBread,
    this.initialStep = 0,
  });

  final BreadCommonResponse? initialBread;
  final int initialStep;

  bool get isEditMode => initialBread != null;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BossBreadCreateProvider(
        initialBread: initialBread,
        initialStep: initialStep,
      ),
      child: _BossBreadCreateView(initialBread: initialBread),
    );
  }
}

class _BossBreadCreateView extends StatelessWidget {
  const _BossBreadCreateView({required this.initialBread});

  final BreadCommonResponse? initialBread;

  static const int _totalSteps = 4;

  bool get isEditMode => initialBread != null;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BossBreadCreateProvider>();
    final breadProvider = context.watch<BreadProvider>();

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                Row(
                  children: [
                    const Text(
                      '등록 진행상황',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7C7C7C),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${provider.currentStep + 1}/$_totalSteps',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (provider.currentStep + 1) / _totalSteps,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE3E3E3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryBackground,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Expanded(
                  child: SingleChildScrollView(
                    child: _BreadCreateStepBody(step: provider.currentStep),
                  ),
                ),
                if (provider.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD64545),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (!isEditMode && provider.currentStep > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: provider.previousStep,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            side: const BorderSide(color: Color(0xFFD8D8D8)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '이전',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: breadProvider.isLoading
                            ? null
                            : () => _handlePrimaryAction(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          backgroundColor: AppColors.primaryBackground,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          breadProvider.isLoading
                              ? '처리 중...'
                              : isEditMode
                              ? '완료'
                              : provider.isLastStep
                              ? '새메뉴 추가하기'
                              : '다음',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
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
              icon: Icon(
                isEditMode
                    ? Icons.close_rounded
                    : Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF4A3A3A),
                size: 26,
              ),
            ),
          ),
          Center(
            child: Text(
              isEditMode ? '메뉴 수정' : '새 메뉴 추가',
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

  Future<void> _handlePrimaryAction(BuildContext context) async {
    final provider = context.read<BossBreadCreateProvider>();
    final wasLastStep = provider.isLastStep;
    final isValid = isEditMode
        ? provider.validateCurrentStep()
        : provider.nextStep();
    if (!isValid) {
      return;
    }
    if (!isEditMode && !wasLastStep) {
      return;
    }

    final breadProvider = context.read<BreadProvider>();
    try {
      final response = isEditMode
          ? await breadProvider.updateBread(
              breadId: initialBread!.id,
              request: provider.buildRequest(),
              image: provider.imageFile,
            )
          : await breadProvider.createBread(
              provider.buildRequest(),
              provider.imageFile,
            );
      if (!context.mounted) {
        return;
      }
      if (response == null) {
        await _showDialog(
          context,
          title: isEditMode ? '수정 실패' : '등록 실패',
          message:
              breadProvider.errorMessage ??
              (isEditMode ? '메뉴 수정에 실패했습니다.' : '메뉴 등록에 실패했습니다.'),
        );
        return;
      }

      await _showDialog(
        context,
        title: isEditMode ? '수정 완료' : '등록 완료',
        message: isEditMode ? '메뉴 수정이 완료되었습니다.' : '메뉴 등록이 완료되었습니다.',
      );
      if (!context.mounted) {
        return;
      }
      Navigator.pop(context, response);
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      await _showDialog(
        context,
        title: isEditMode ? '수정 불가' : '등록 불가',
        message: ApiException.messageFrom(e),
      );
    }
  }

  Future<void> _showDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryBackground,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}

class _BreadCreateStepBody extends StatelessWidget {
  final int step;

  const _BreadCreateStepBody({required this.step});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BossBreadCreateProvider>();

    switch (step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '메뉴명을 입력해주세요',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              initialValue: provider.name,
              onChanged: context.read<BossBreadCreateProvider>().updateName,
              decoration: _inputDecoration('단팥빵'),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '가격 및 수량을 입력해주세요',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '가격은 상품의 원가, 할인가 모두 입력해주세요',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF7C7C7C),
              ),
            ),
            const SizedBox(height: 22),
            const _BreadFieldLabel('원가'),
            const SizedBox(height: 10),
            _PriceField(
              value: provider.originalPrice,
              onChanged: context
                  .read<BossBreadCreateProvider>()
                  .updateOriginalPrice,
            ),
            const SizedBox(height: 14),
            const _BreadFieldLabel('할인가'),
            const SizedBox(height: 10),
            _PriceField(
              value: provider.salePrice,
              onChanged: context
                  .read<BossBreadCreateProvider>()
                  .updateSalePrice,
            ),
            const SizedBox(height: 14),
            const _BreadFieldLabel('수량'),
            const SizedBox(height: 10),
            Row(
              children: [
                _QuantityButton(
                  label: '-',
                  onTap: context
                      .read<BossBreadCreateProvider>()
                      .decrementQuantity,
                ),
                Container(
                  width: 72,
                  height: 52,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                  ),
                  child: Text(
                    '${provider.quantity}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
                _QuantityButton(
                  label: '+',
                  onTap: context
                      .read<BossBreadCreateProvider>()
                      .incrementQuantity,
                ),
              ],
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '메뉴판에 사용될 상품 사진을 등록해주세요',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '실제 판매될 상품의 사진을 등록해주세요',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF7C7C7C),
              ),
            ),
            const SizedBox(height: 22),
            InkWell(
              onTap: () => _showImagePicker(context),
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD9D9D9)),
                ),
                child:
                    provider.imageFile == null &&
                        provider.initialImageUrl == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 44,
                            color: Color(0xFF9C9C9C),
                          ),
                          SizedBox(height: 14),
                          Text(
                            '이미지 등록',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6F6F6F),
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (provider.imageFile != null)
                              Image.file(
                                File(provider.imageFile!.path),
                                fit: BoxFit.cover,
                              )
                            else
                              AppNetworkImage(
                                imageUrl: provider.initialImageUrl,
                                fit: BoxFit.cover,
                                placeholder: Container(
                                  color: const Color(0xFFF1F1F1),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    color: Color(0xFF8D8D8D),
                                    size: 42,
                                  ),
                                ),
                              ),
                            if (provider.imageFile != null)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: InkWell(
                                  onTap: context
                                      .read<BossBreadCreateProvider>()
                                      .clearImage,
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.45,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '등록될 메뉴에 대한 설명을 적어주세요',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '메뉴에 대한 설명은 255자로 제한됩니다',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF7C7C7C),
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              initialValue: provider.description,
              onChanged: context
                  .read<BossBreadCreateProvider>()
                  .updateDescription,
              maxLines: 6,
              maxLength: 255,
              decoration: _inputDecoration('메뉴 설명을 입력해주세요'),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _showImagePicker(BuildContext context) async {
    final picker = ImagePicker();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '상품 이미지 선택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('갤러리에서 선택'),
                  onTap: () async {
                    final image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    if (image != null) {
                      context.read<BossBreadCreateProvider>().updateImage(
                        image,
                      );
                    }
                    Navigator.of(bottomSheetContext).pop();
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('카메라로 촬영'),
                  onTap: () async {
                    final image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    if (image != null) {
                      context.read<BossBreadCreateProvider>().updateImage(
                        image,
                      );
                    }
                    Navigator.of(bottomSheetContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
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
}

class _BreadFieldLabel extends StatelessWidget {
  final String label;

  const _BreadFieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Colors.black,
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _PriceField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: value,
              keyboardType: TextInputType.number,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: '0',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: Text(
              '원',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuantityButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
