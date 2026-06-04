import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/config/app_config.dart';
import 'package:todaybread/models/store/business_hours_request.dart';
import 'package:todaybread/models/store/store_common_request.dart';
import 'package:todaybread/models/store/store_image_response.dart';
import 'package:todaybread/models/store/store_info_response.dart';
import 'package:todaybread/providers/store/store_provider.dart';
import 'package:todaybread/utils/app_colors.dart';
import 'package:todaybread/utils/business_hours_helper.dart';
import 'package:todaybread/utils/user_input_helper.dart';
import 'package:todaybread/widgets/app_network_image.dart';
import 'package:todaybread/widgets/business_hours_editor.dart';

/// 매장관리에서 각 항목의 연필 버튼을 눌렀을 때 열리는 공용 수정 화면입니다.
///
/// 어떤 항목을 수정하는지 [StoreEditMode]로 전달받고,
/// 저장 시에는 StoreProvider를 통해 전체 매장 정보 또는 이미지 API를 호출합니다.
enum StoreEditMode { image, location, name, phone, description, operation }

class BossStoreEditScreen extends StatefulWidget {
  final StoreInfoResponse storeInfo;
  final StoreEditMode mode;

  const BossStoreEditScreen({
    super.key,
    required this.storeInfo,
    required this.mode,
  });

  @override
  State<BossStoreEditScreen> createState() => _BossStoreEditScreenState();
}

class _BossStoreEditScreenState extends State<BossStoreEditScreen> {
  late final TextEditingController _address1Controller;
  late final TextEditingController _address2Controller;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _descriptionController;
  late List<StoreImageResponse> _keptImages;
  final List<XFile> _newImages = [];

  late List<BusinessHoursRequest> _businessHours;
  late BusinessHoursRequest _templateBusinessHours;

  String? _localError;
  String? _phoneCheckMessage;

  @override
  void initState() {
    super.initState();
    final store = widget.storeInfo.store;
    _keptImages = List.from(widget.storeInfo.images);
    _address1Controller = TextEditingController(text: store.addressLine1);
    _address2Controller = TextEditingController(text: store.addressLine2);
    _nameController = TextEditingController(text: store.name);
    _phoneController = TextEditingController(text: store.phone);
    _descriptionController = TextEditingController(text: store.description);
    _businessHours =
        store.businessHours.map((value) => value.toRequest()).toList()
          ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
    _templateBusinessHours = _buildInitialTemplate(_businessHours);
  }

  @override
  void dispose() {
    _address1Controller.dispose();
    _address2Controller.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBody(),
                      if (_localError != null ||
                          storeProvider.errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _localError ?? storeProvider.errorMessage!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD64545),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: storeProvider.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBackground,
                    foregroundColor: AppColors.onPrimaryBackground,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: storeProvider.isLoading
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
              '${_titleForMode(widget.mode)} 수정',
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

  Widget _buildBody() {
    switch (widget.mode) {
      case StoreEditMode.image:
        return _buildImageEditor();
      case StoreEditMode.location:
        return _buildLocationEditor();
      case StoreEditMode.name:
        return _buildTextEditor(
          label: '매장 이름',
          controller: _nameController,
          hintText: '매장 이름을 입력해주세요',
        );
      case StoreEditMode.phone:
        return _buildPhoneEditor();
      case StoreEditMode.description:
        return _buildDescriptionEditor();
      case StoreEditMode.operation:
        return _buildOperationEditor();
    }
  }

  Widget _buildImageEditor() {
    final totalCount = _keptImages.length + _newImages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '매장 이미지 관리',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'X 버튼으로 이미지를 삭제하거나 새 이미지를 추가할 수 있습니다. 최대 5장까지 가능합니다.',
          style: TextStyle(
            fontSize: 13,
            height: 1.45,
            color: Color(0xFF7C7C7C),
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // 기존 이미지 (유지 중인 것)
            ..._keptImages.map(
              (image) => _buildImageTile(
                child: AppNetworkImage(
                  imageUrl: image.imageUrl,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  placeholder: _imageFallback(),
                ),
                onDelete: () => setState(() => _keptImages.remove(image)),
              ),
            ),
            // 새로 추가한 이미지
            ..._newImages.map(
              (image) => _buildImageTile(
                child: Image.file(
                  File(image.path),
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
                onDelete: () => setState(() => _newImages.remove(image)),
              ),
            ),
            // 추가 버튼 (5장 미만일 때)
            if (totalCount < 5)
              GestureDetector(
                onTap: _showImageSourcePicker,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF8D8D8D),
                    size: 32,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageTile({
    required Widget child,
    required VoidCallback onDelete,
  }) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(14), child: child),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourcePicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리 선택'),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라 촬영'),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('매장 위치'),
        const SizedBox(height: 10),
        TextField(
          controller: _address1Controller,
          decoration: _inputDecoration('주소를 입력해주세요'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _address2Controller,
          decoration: _inputDecoration('상세 주소를 입력해주세요'),
        ),
      ],
    );
  }

  Widget _buildPhoneEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('매장 전화번호'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: const [StorePhoneNumberTextInputFormatter()],
                decoration: _inputDecoration('매장 전화번호를 입력해주세요'),
                onChanged: (_) {
                  setState(() {
                    _phoneCheckMessage = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _handlePhoneCheck,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBackground,
                  foregroundColor: AppColors.onPrimaryBackground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '중복확인',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        if (_phoneCheckMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _phoneCheckMessage!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5E5E5E),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescriptionEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('매장 소개'),
        const SizedBox(height: 10),
        TextField(
          controller: _descriptionController,
          maxLines: 6,
          maxLength: 255,
          decoration: _inputDecoration('매장 소개 글을 입력해주세요'),
        ),
      ],
    );
  }

  Widget _buildOperationEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '요일별 영업시간을 수정해주세요',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '각 요일을 개별 수정할 수 있고, 공통 시간으로 전체/평일/주말 일괄 적용도 가능합니다.',
          style: TextStyle(
            fontSize: 13,
            height: 1.45,
            color: Color(0xFF7C7C7C),
          ),
        ),
        const SizedBox(height: 22),
        BusinessHoursEditor(
          template: _templateBusinessHours,
          businessHours: _businessHours,
          onTemplateChanged: (value) {
            setState(() {
              _templateBusinessHours = value;
            });
          },
          onApplyTemplateToAll: () =>
              _applyTemplate(const [1, 2, 3, 4, 5, 6, 7]),
          onApplyTemplateToWeekdays: () =>
              _applyTemplate(const [1, 2, 3, 4, 5]),
          onApplyTemplateToWeekend: () => _applyTemplate(const [6, 7]),
          onDayChanged: (value) {
            setState(() {
              _businessHours =
                  _businessHours
                      .map(
                        (hours) =>
                            hours.dayOfWeek == value.dayOfWeek ? value : hours,
                      )
                      .toList()
                    ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
            });
          },
        ),
      ],
    );
  }

  Widget _buildTextEditor({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: _inputDecoration(hintText),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Colors.black,
      ),
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

  Future<void> _pickFromGallery() async {
    final remaining = 5 - _keptImages.length - _newImages.length;
    if (remaining <= 0) return;
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(limit: remaining);
    if (images.isEmpty) return;
    setState(() => _newImages.addAll(images));
  }

  Future<void> _pickFromCamera() async {
    final remaining = 5 - _keptImages.length - _newImages.length;
    if (remaining <= 0) return;
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image == null) return;
    setState(() => _newImages.add(image));
  }

  /// 기존 이미지 URL을 임시 파일로 다운로드합니다.
  Future<XFile> _downloadImageAsXFile(StoreImageResponse image) async {
    final dio = Dio();
    final baseUrl = AppConfig.apiBaseUrl;
    final url = image.imageUrl.startsWith('http')
        ? image.imageUrl
        : '$baseUrl${image.imageUrl}';
    final Response<Uint8List> response = await dio.get<Uint8List>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/kept_${image.id}.jpg')
      ..writeAsBytesSync(response.data!);
    return XFile(file.path);
  }

  void _handlePhoneCheck() {
    final phone = _phoneController.text.trim();
    setState(() {
      if (phone.isEmpty) {
        _phoneCheckMessage = '매장 전화번호를 입력해주세요.';
      } else if (!UserInputHelper.isValidStorePhoneNumber(phone)) {
        _phoneCheckMessage = '매장 전화번호는 02-0000-0000 형식으로 입력해주세요.';
      } else if (phone == widget.storeInfo.store.phone) {
        _phoneCheckMessage = '현재 사용 중인 전화번호입니다.';
      } else {
        _phoneCheckMessage = '중복확인 전용 API가 없어 저장 시 서버에서 최종 확인됩니다.';
      }
    });
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _localError = null;
    });

    if (widget.mode == StoreEditMode.image) {
      if (_keptImages.isEmpty && _newImages.isEmpty) {
        setState(() {
          _localError = '매장 이미지를 1장 이상 유지하거나 추가해주세요.';
        });
        return;
      }
      // 유지할 기존 이미지를 다운로드 후 새 이미지와 합쳐서 전송
      List<XFile> allImages;
      try {
        final downloaded = await Future.wait(
          _keptImages.map(_downloadImageAsXFile),
        );
        allImages = [...downloaded, ..._newImages];
      } catch (_) {
        setState(() {
          _localError = '이미지 처리 중 오류가 발생했습니다. 다시 시도해주세요.';
        });
        return;
      }
      final response = await context.read<StoreProvider>().updateImages(
        allImages,
      );
      if (!mounted) return;
      if (response != null) {
        Navigator.pop(context, true);
      }
      return;
    }

    final request = _buildRequest();
    if (request == null) {
      return;
    }

    final response = await context.read<StoreProvider>().updateStore(request);
    if (!mounted) {
      return;
    }
    if (response != null) {
      Navigator.pop(context, true);
    }
  }

  StoreCommonRequest? _buildRequest() {
    final store = widget.storeInfo.store;
    final name = widget.mode == StoreEditMode.name
        ? _nameController.text.trim()
        : store.name;
    final phone = widget.mode == StoreEditMode.phone
        ? _phoneController.text.trim()
        : store.phone;
    final description = widget.mode == StoreEditMode.description
        ? _descriptionController.text.trim()
        : store.description;
    final addressLine1 = widget.mode == StoreEditMode.location
        ? _address1Controller.text.trim()
        : store.addressLine1;
    final addressLine2 = widget.mode == StoreEditMode.location
        ? _address2Controller.text.trim()
        : store.addressLine2;

    if (name.isEmpty ||
        phone.isEmpty ||
        description.isEmpty ||
        addressLine1.isEmpty ||
        addressLine2.isEmpty) {
      setState(() {
        _localError = '모든 필수 값을 입력해주세요.';
      });
      return null;
    }

    if (!UserInputHelper.isValidStorePhoneNumber(phone)) {
      setState(() {
        _localError = '매장 전화번호는 02-0000-0000 형식으로 입력해주세요.';
      });
      return null;
    }

    for (final value in _businessHours) {
      final error = validateBusinessHoursValues(
        isClosed: value.isClosed,
        startTime: value.startTime,
        endTime: value.endTime,
        lastOrderTime: value.lastOrderTime,
        label: '${weekdayLabel(value.dayOfWeek)}요일',
      );
      if (error != null) {
        setState(() {
          _localError = error;
        });
        return null;
      }
    }

    return StoreCommonRequest(
      name: name,
      phone: phone,
      description: description,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      latitude: store.latitude,
      longitude: store.longitude,
      businessHours: _businessHours,
    );
  }

  BusinessHoursRequest _buildInitialTemplate(
    List<BusinessHoursRequest> values,
  ) {
    for (final value in values) {
      if (!value.isClosed) {
        return value.copyWith(dayOfWeek: 1);
      }
    }
    return const BusinessHoursRequest(
      dayOfWeek: 1,
      isClosed: false,
      startTime: defaultBusinessStartTime,
      endTime: defaultBusinessEndTime,
      lastOrderTime: defaultBusinessLastOrderTime,
    );
  }

  void _applyTemplate(List<int> targetDays) {
    setState(() {
      _businessHours = _businessHours.map((value) {
        if (!targetDays.contains(value.dayOfWeek)) {
          return value;
        }
        return value.copyWith(
          isClosed: _templateBusinessHours.isClosed,
          startTime: _templateBusinessHours.isClosed
              ? null
              : _templateBusinessHours.startTime,
          endTime: _templateBusinessHours.isClosed
              ? null
              : _templateBusinessHours.endTime,
          lastOrderTime: _templateBusinessHours.isClosed
              ? null
              : _templateBusinessHours.lastOrderTime,
        );
      }).toList()..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
    });
  }

  String _titleForMode(StoreEditMode mode) {
    switch (mode) {
      case StoreEditMode.image:
        return '매장 이미지';
      case StoreEditMode.location:
        return '매장 위치';
      case StoreEditMode.name:
        return '매장 이름';
      case StoreEditMode.phone:
        return '매장 전화번호';
      case StoreEditMode.description:
        return '매장 소개';
      case StoreEditMode.operation:
        return '운영 정보';
    }
  }

  Widget _imageFallback() {
    return Container(
      width: 96,
      height: 96,
      color: const Color(0xFFF1F1F1),
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined, color: Color(0xFF8D8D8D)),
    );
  }
}
