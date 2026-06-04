import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todaybread/models/order/order_detail_response.dart';
import 'package:todaybread/models/order/order_item_response.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/services/review/review_service.dart';
import 'package:todaybread/utils/app_assets.dart';
import 'package:todaybread/utils/app_colors.dart';
import 'package:todaybread/widgets/app_network_image.dart';

class ReviewCreateScreen extends StatefulWidget {
  const ReviewCreateScreen({
    super.key,
    required this.order,
    required this.item,
  });

  final OrderDetailResponse order;
  final OrderItemResponse item;

  @override
  State<ReviewCreateScreen> createState() => _ReviewCreateScreenState();
}

class _ReviewCreateScreenState extends State<ReviewCreateScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _images = [];

  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectImageSource() async {
    if (_images.length >= 2) {
      _showSnackBar('리뷰 이미지는 최대 2장까지 첨부할 수 있습니다.');
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('갤러리에서 선택'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('사진 촬영'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (image == null || !mounted) {
      return;
    }

    setState(() {
      _images.add(image);
    });
  }

  Future<void> _submit() async {
    final orderItemId = widget.item.orderItemId;
    final content = _contentController.text.trim();

    if (_isSubmitting) {
      return;
    }
    if (orderItemId == null) {
      _showSnackBar('리뷰 작성을 위해 주문 항목 ID가 필요합니다.');
      return;
    }
    if (_rating <= 0) {
      _showSnackBar('별점을 선택해주세요.');
      return;
    }
    if (content.length < 10) {
      _showSnackBar('리뷰는 10자 이상 입력해주세요.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ReviewService.instance.createReview(
        orderItemId: orderItemId,
        rating: _rating,
        content: content,
        images: _images,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showSnackBar(ApiException.messageFrom(e));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
        ),
        title: const Text(
          '리뷰 작성하기',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSummaryCard(),
                    const SizedBox(height: 28),
                    Center(
                      child: _StarRatingSelector(
                        rating: _rating,
                        onChanged: (value) {
                          setState(() {
                            _rating = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildImagePicker(),
                    const SizedBox(height: 30),
                    const Text(
                      '리뷰 작성',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _contentController,
                      minLines: 6,
                      maxLines: 8,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: '매장에 대한 리뷰를 적어주세요!',
                        hintStyle: const TextStyle(color: Color(0xFFB5B5B5)),
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE4E4E4),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE4E4E4),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBackground,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBackground,
                    foregroundColor: AppColors.onPrimaryBackground,
                    disabledBackgroundColor: AppColors.primaryBackground
                        .withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.onPrimaryBackground,
                          ),
                        )
                      : const Text(
                          '작성 완료',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final items = widget.order.items;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9E9E9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'PretendardVariable',
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: Color(0xFF202020),
              ),
              children: [
                TextSpan(
                  text: widget.order.storeName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const TextSpan(text: '에서의 픽업 경험은 어떠셨나요?'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '구매 상품',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF5A5A5A),
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PurchasedItemRow(item: item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (int index = 0; index < _images.length; index++)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(_images[index].path),
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _images.removeAt(index);
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
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
        if (_images.length < 2)
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _selectImageSource,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE1E1E1)),
              ),
              child: const Icon(
                Icons.image_outlined,
                size: 34,
                color: Color(0xFF8D8D8D),
              ),
            ),
          ),
      ],
    );
  }
}

class _PurchasedItemRow extends StatelessWidget {
  const _PurchasedItemRow({required this.item});

  final OrderItemResponse item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 48,
            height: 48,
            child: AppNetworkImage(
              imageUrl: item.breadImageUrl,
              fit: BoxFit.cover,
              placeholder: Image.asset(AppAssets.breadImage, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.breadName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF202020),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${item.quantity}개',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF8A8A8A),
          ),
        ),
      ],
    );
  }
}

class _StarRatingSelector extends StatelessWidget {
  const _StarRatingSelector({required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          children: List.generate(5, (index) {
            final value = index + 1;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(value),
              child: SizedBox(
                width: 38,
                height: 44,
                child: Icon(
                  rating >= value ? Icons.star_rounded : Icons.star_rounded,
                  size: 36,
                  color: rating >= value
                      ? const Color(0xFFFFC107)
                      : const Color(0xFFD7D7D7),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          rating == 0 ? '별점을 선택해주세요' : '$rating점',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B6B6B),
          ),
        ),
      ],
    );
  }
}
