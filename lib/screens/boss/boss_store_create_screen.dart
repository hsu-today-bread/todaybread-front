import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/boss/boss_store_create_provider.dart';
import 'package:todaybread/providers/store/store_provider.dart';
import 'package:todaybread/screens/boss/boss_switching_screen.dart';
import 'package:todaybread/services/geocoding/naver_geocoding_service.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/utils/app_colors.dart';
import 'package:todaybread/utils/user_input_helper.dart';
import 'package:todaybread/widgets/business_hours_editor.dart';

enum StoreCreateCompletionMode { returnToPrevious, switchToBoss }

class BossStoreCreateScreen extends StatelessWidget {
  const BossStoreCreateScreen({
    super.key,
    this.completionMode = StoreCreateCompletionMode.returnToPrevious,
  });

  final StoreCreateCompletionMode completionMode;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // 매장 등록 step 입력값은 이 화면 생명주기 동안만 유지하면 되므로
      // 전역이 아니라 화면 진입 시 생성하는 local provider로 둔다.
      create: (_) => BossStoreCreateProvider(),
      child: _BossStoreCreateView(completionMode: completionMode),
    );
  }
}

class _BossStoreCreateView extends StatelessWidget {
  const _BossStoreCreateView({required this.completionMode});

  final StoreCreateCompletionMode completionMode;

  static const int _totalSteps = 6;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BossStoreCreateProvider>();
    final storeProvider = context.watch<StoreProvider>();

    return PopScope(
      canPop: completionMode == StoreCreateCompletionMode.returnToPrevious,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                      // 멀티페이지로 나누지 않고, currentStep 값에 따라
                      // 한 화면 안에서 다른 입력 뷰를 보여준다.
                      child: _StoreCreateStepBody(step: provider.currentStep),
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
                      if (provider.currentStep > 0) ...[
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
                          onPressed: storeProvider.isLoading
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
                            storeProvider.isLoading
                                ? '처리 중...'
                                : provider.isLastStep
                                ? '완료하기'
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
            child: completionMode == StoreCreateCompletionMode.returnToPrevious
                ? IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF4A3A3A),
                      size: 26,
                    ),
                  )
                : const SizedBox(width: 48),
          ),
          const Center(
            child: Text(
              '매장 등록',
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

  Future<void> _handlePrimaryAction(BuildContext context) async {
    final provider = context.read<BossStoreCreateProvider>();
    final wasLastStep = provider.isLastStep;

    // 다음/완료 버튼은 항상 현재 step 유효성 검사를 먼저 통과해야 한다.
    final isValid = provider.nextStep();
    if (!isValid) {
      _showSnackBar(context, provider.errorMessage ?? '입력값을 확인해주세요.');
      return;
    }

    if (!wasLastStep) {
      return;
    }

    final storeProvider = context.read<StoreProvider>();
    try {
      // 마지막 step에서는 draft 상태를 StoreCommonRequest로 묶어
      // 실제 가게 등록 API를 호출한다. UI가 서비스를 직접 부르지 않고
      // StoreProvider를 거치도록 분리한 이유가 여기 있다.
      final response = await storeProvider.createStore(
        provider.buildRequest(),
        provider.imageFiles,
      );
      if (!context.mounted) {
        return;
      }

      if (response == null) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('등록 실패'),
              content: Text(storeProvider.errorMessage ?? '매장 등록에 실패했습니다.'),
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
        return;
      }

      if (completionMode == StoreCreateCompletionMode.switchToBoss) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const BossSwitchingScreen()),
          (route) => false,
        );
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('등록 완료'),
            content: const Text('매장 등록이 완료되었습니다.'),
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

      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('등록 불가'),
            content: Text(
              e is FormatException
                  ? '현재는 주소만 입력받고 있어 위도/경도 값이 없습니다. 주소 검색 또는 지도 선택 기능을 먼저 붙여야 합니다.'
                  : ApiException.messageFrom(e),
            ),
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

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _StoreCreateStepBody extends StatelessWidget {
  final int step;

  const _StoreCreateStepBody({required this.step});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BossStoreCreateProvider>();

    // step 번호에 따라 완전히 다른 입력 view를 반환한다.
    // 현재는 주소 -> 이름 -> 전화번호 -> 로고 -> 영업시간 -> 소개글 순서다.
    switch (step) {
      case 0:
        return _AddressStep(
          initialAddressLine2: provider.addressLine2,
          selectedAddress: provider.addressLine1,
          inputDecoration: _inputDecoration,
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '매장 이름을 입력해주세요',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              key: const ValueKey('store_name'),
              initialValue: provider.name,
              onChanged: context.read<BossStoreCreateProvider>().updateName,
              decoration: _inputDecoration('매장 이름을 입력해주세요'),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '매장 전화번호를 입력해주세요',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              key: const ValueKey('store_phone'),
              initialValue: provider.phone,
              keyboardType: TextInputType.phone,
              inputFormatters: const [StorePhoneNumberTextInputFormatter()],
              onChanged: context.read<BossStoreCreateProvider>().updatePhone,
              decoration: _inputDecoration('02-0000-0000'),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '매장 이미지를 등록해주세요',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 22),
            InkWell(
              onTap: () => _showLogoPicker(context),
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD9D9D9)),
                ),
                child: provider.imageFiles.isEmpty
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
                            '이미지 최대 5장 선택',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6F6F6F),
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '선택된 이미지 ${provider.imageFiles.length}/5',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              child: GridView.builder(
                                itemCount: provider.imageFiles.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                itemBuilder: (context, index) {
                                  final imageFile = provider.imageFiles[index];
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.file(
                                          File(imageFile.path),
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          right: 6,
                                          top: 6,
                                          child: GestureDetector(
                                            onTap: () {
                                              context
                                                  .read<
                                                    BossStoreCreateProvider
                                                  >()
                                                  .removeImageAt(index);
                                            },
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              decoration: const BoxDecoration(
                                                color: Color(0xB3000000),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '요일별 영업시간을 설정해주세요',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '요일별로 개별 설정할 수 있고, 공통 시간으로 전체/평일/주말 일괄 적용도 가능합니다.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF7C7C7C),
              ),
            ),
            const SizedBox(height: 22),
            BusinessHoursEditor(
              template: provider.templateBusinessHours,
              businessHours: provider.businessHours,
              onTemplateChanged: context
                  .read<BossStoreCreateProvider>()
                  .updateTemplateBusinessHours,
              onApplyTemplateToAll: context
                  .read<BossStoreCreateProvider>()
                  .applyTemplateToAll,
              onApplyTemplateToWeekdays: context
                  .read<BossStoreCreateProvider>()
                  .applyTemplateToWeekdays,
              onApplyTemplateToWeekend: context
                  .read<BossStoreCreateProvider>()
                  .applyTemplateToWeekend,
              onDayChanged: context
                  .read<BossStoreCreateProvider>()
                  .updateBusinessHours,
            ),
          ],
        );
      case 5:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '매장에 대한 간단한 소개를 적어주세요',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '매장에 대한 소개는 255자로 제한됩니다',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF7C7C7C),
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              key: const ValueKey('description'),
              initialValue: provider.description,
              onChanged: context
                  .read<BossStoreCreateProvider>()
                  .updateDescription,
              maxLines: 6,
              maxLength: 255,
              decoration: _inputDecoration('매장 소개 글을 입력해주세요'),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _showLogoPicker(BuildContext context) async {
    final provider = context.read<BossStoreCreateProvider>();
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
                  '매장 이미지 선택',
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
                  subtitle: const Text('여러 장 선택 가능, 최대 5장'),
                  onTap: () async {
                    final images = await picker.pickMultiImage(
                      imageQuality: 85,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    final message = provider.replaceImages(images);
                    Navigator.of(bottomSheetContext).pop();
                    if (!context.mounted || message == null) {
                      return;
                    }
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('카메라로 촬영'),
                  subtitle: const Text('한 장씩 추가, 최대 5장'),
                  onTap: () async {
                    final image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    String? message;
                    if (image != null) {
                      message = provider.addImage(image);
                    }
                    Navigator.of(bottomSheetContext).pop();
                    if (!context.mounted || message == null) {
                      return;
                    }
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
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

class _AddressStep extends StatefulWidget {
  final String initialAddressLine2;
  final String selectedAddress;
  final InputDecoration Function(String) inputDecoration;

  const _AddressStep({
    required this.initialAddressLine2,
    required this.selectedAddress,
    required this.inputDecoration,
  });

  @override
  State<_AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends State<_AddressStep> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<GeocodingResult> _results = [];
  bool _isSearching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    // 이미 선택된 주소가 있으면 검색창에 표시
    if (widget.selectedAddress.isNotEmpty) {
      _searchController.text = widget.selectedAddress;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _searchError = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() {
      _isSearching = true;
      _searchError = null;
    });
    try {
      final results = await NaverGeocodingService.search(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _isSearching = false;
        if (results.isEmpty) {
          _searchError = '검색 결과가 없습니다. 도로명이나 지번을 조금 더 자세히 입력해주세요.';
        }
      });
    } catch (e) {
      debugPrint('[Geocoding] search error: $e');
      if (!mounted) return;
      setState(() {
        _results = [];
        _isSearching = false;
        _searchError = _searchErrorMessage(e);
      });
    }
  }

  String _searchErrorMessage(Object error) {
    if (error is GeocodingException) {
      switch (error.type) {
        case GeocodingErrorType.missingCredentials:
          return '주소 검색 설정이 없습니다. 앱을 완전히 종료한 뒤 실행 옵션을 확인해주세요.';
        case GeocodingErrorType.unauthorized:
        case GeocodingErrorType.forbidden:
        case GeocodingErrorType.apiDenied:
          return '주소 검색 인증에 실패했습니다. Naver Client ID/Secret과 Geocoding 활성화를 확인해주세요.';
        case GeocodingErrorType.quotaExceeded:
          return '주소 검색 사용량 또는 서비스 설정을 확인해주세요.';
        case GeocodingErrorType.badRequest:
          return '도로명이나 지번 주소를 조금 더 정확히 입력해주세요.';
        case GeocodingErrorType.network:
          return '네트워크 연결을 확인한 뒤 다시 시도해주세요.';
        case GeocodingErrorType.invalidResponse:
        case GeocodingErrorType.unknown:
          return '주소 검색 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      }
    }
    return '주소 검색 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
  }

  void _selectResult(GeocodingResult result) {
    context.read<BossStoreCreateProvider>().selectAddress(
      result.displayAddress,
      result.latitude,
      result.longitude,
    );
    _searchController.text = result.displayAddress;
    setState(() {
      _results = [];
      _searchError = null;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BossStoreCreateProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '매장 위치에 대한 정보를 입력해주세요',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 22),

        /// 주소 검색창
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: widget
              .inputDecoration('지번, 도로명 검색')
              .copyWith(
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search, color: Colors.black38),
              ),
        ),

        /// 선택된 주소 표시
        if (provider.addressLine1.isNotEmpty && _results.isEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryBackground.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.primaryBackground,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    provider.addressLine1,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],

        /// 검색 결과 목록
        if (_results.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD9D9D9)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _results.length,
              separatorBuilder: (context, i) =>
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
              itemBuilder: (context, index) {
                final result = _results[index];
                return InkWell(
                  onTap: () => _selectResult(result),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (result.roadAddress.isNotEmpty)
                          Text(
                            result.roadAddress,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        if (result.jibunAddress.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            result.jibunAddress,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        /// 검색 오류/결과 없음 메시지
        if (_searchError != null) ...[
          const SizedBox(height: 8),
          Text(
            _searchError!,
            style: const TextStyle(fontSize: 13, color: Colors.black45),
          ),
        ],

        const SizedBox(height: 18),

        /// 상세 주소
        TextFormField(
          key: const ValueKey('address_line2'),
          initialValue: widget.initialAddressLine2,
          onChanged: context.read<BossStoreCreateProvider>().updateAddressLine2,
          decoration: widget.inputDecoration('상세 주소 입력'),
        ),
      ],
    );
  }
}
