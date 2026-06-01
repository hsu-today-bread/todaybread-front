import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todaybread/widgets/skeleton.dart';
import '../../utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/models/interest_area/interest_area_response.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/providers/wishlist/wishlist_provider.dart';
import 'package:todaybread/services/geocoding/naver_geocoding_service.dart';
import 'package:todaybread/services/network/api_exception.dart';
import 'package:todaybread/widgets/app_network_image.dart';

class WishScreen extends StatefulWidget {
  const WishScreen({super.key});

  @override
  State<WishScreen> createState() => _WishScreenState();
}

class _WishScreenState extends State<WishScreen> {
  final TextEditingController _keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || context.read<AuthProvider>().role != UserRole.user) {
        return;
      }
      context.read<WishlistProvider>().load();
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '키워드 관리',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _InterestAreaCard(
                interestArea: wishlistProvider.interestArea,
                isLoading: wishlistProvider.isInterestAreaLoading,
                errorMessage: wishlistProvider.interestAreaErrorMessage,
                onSetup: () => _showInterestAreaSetupSheet(context),
                onDelete: () => _deleteInterestArea(context),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _keywordController,
                      maxLength: 10,
                      decoration: InputDecoration(
                        hintText: '등록할 키워드를 입력해주세요',
                        hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBackground,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: ElevatedButton(
                      onPressed: wishlistProvider.isLoading
                          ? null
                          : () => _addKeyword(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBackground,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('키워드 추가'),
                    ),
                  ),
                ],
              ),
              if (wishlistProvider.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  wishlistProvider.errorMessage!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFD64545),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              if (wishlistProvider.isLoading)
                const ChipRowSkeleton()
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: wishlistProvider.keywords.map((keyword) {
                    return Chip(
                      label: Text(keyword.displayText),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      deleteIcon: const Icon(Icons.cancel, size: 18),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 0,
                      ),
                      onDeleted: () async {
                        try {
                          await context.read<WishlistProvider>().removeKeyword(
                            keyword.userKeywordId,
                          );
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.read<WishlistProvider>().errorMessage ??
                                    '키워드 삭제에 실패했습니다.',
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 32),
              const Text(
                '단골 매장 관리',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                '하트 클릭 시 단골 매장이 해제됩니다.',
                style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 16),
              if (wishlistProvider.isLoading)
                const BreadCardSkeletonColumn(count: 2)
              else if (wishlistProvider.favouriteStores.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      '단골 매장이 없습니다.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
                    ),
                  ),
                )
              else
                Column(
                  children: wishlistProvider.favouriteStores.map((store) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                ClipOval(
                                  child: AppNetworkImage(
                                    imageUrl: store.imageUrl,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    placeholder: _storePlaceholder(),
                                  ),
                                ),
                                if (!store.isSelling)
                                  ClipOval(
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      color: Colors.black54,
                                      alignment: Alignment.center,
                                      child: const Text(
                                        '영업\n종료',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    store.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    store.address,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                final storeName = store.name;
                                final success = await context
                                    .read<WishlistProvider>()
                                    .toggleStore(store.storeId);
                                if (!context.mounted || !success) {
                                  return;
                                }
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text('$storeName 단골 매장 해제'),
                                    ),
                                  );
                              },
                              icon: const Icon(
                                Icons.favorite,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _storePlaceholder() {
    return Container(
      width: 64,
      height: 64,
      color: const Color(0xFFEEEEEE),
      child: const Icon(Icons.store, color: Color(0xFFAAAAAA), size: 32),
    );
  }

  Future<void> _addKeyword(BuildContext context) async {
    final text = _keywordController.text.trim();
    if (text.isEmpty) return;

    final provider = context.read<WishlistProvider>();
    final canAdd = await provider.ensureCanAddKeyword();
    if (!context.mounted) return;

    if (!canAdd) {
      if (provider.interestAreaErrorMessage != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(provider.interestAreaErrorMessage!)),
          );
        return;
      }
      final didSetup = await _showInterestAreaSetupSheet(context);
      if (didSetup != true || !context.mounted) {
        return;
      }
    }

    await _submitKeyword(context, text);
  }

  Future<void> _submitKeyword(BuildContext context, String text) async {
    final provider = context.read<WishlistProvider>();
    try {
      await provider.addKeyword(text);
      _keywordController.clear();
    } catch (_) {
      if (!context.mounted) return;
      if (provider.interestArea == null &&
          provider.interestAreaErrorMessage != null) {
        await _showInterestAreaSetupSheet(context);
      }
    }
  }

  Future<bool?> _showInterestAreaSetupSheet(BuildContext context) {
    final provider = context.read<WishlistProvider>();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ChangeNotifierProvider.value(
          value: provider,
          child: const _InterestAreaSetupSheet(),
        );
      },
    );
  }

  Future<void> _deleteInterestArea(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            '관심지역을 삭제할까요?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '기존 키워드는 유지되지만, 관심지역을 다시 설정하기 전까지 키워드 알림은 받을 수 없어요.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('유지하기'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                '삭제',
                style: TextStyle(color: Color(0xFFE0462E)),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    final success = await context.read<WishlistProvider>().deleteInterestArea();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '관심지역이 삭제되어 키워드 알림이 비활성화됐어요.'
                : context.read<WishlistProvider>().interestAreaErrorMessage ??
                      '관심지역 삭제에 실패했습니다.',
          ),
        ),
      );
  }
}

class _InterestAreaCard extends StatelessWidget {
  const _InterestAreaCard({
    required this.interestArea,
    required this.isLoading,
    required this.errorMessage,
    required this.onSetup,
    required this.onDelete,
  });

  final InterestAreaResponse? interestArea;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSetup;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final area = interestArea;
    final hasArea = area != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasArea
            ? const Color(0xFFF8FBFA)
            : AppColors.primaryBackground.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasArea
              ? const Color(0xFFE2EAE7)
              : AppColors.primaryBackground.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  hasArea
                      ? Icons.notifications_active_rounded
                      : Icons.add_location_alt_rounded,
                  color: AppColors.primaryBackground,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasArea ? '키워드 알림 지역' : '관심지역 설정이 필요해요',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF17201D),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hasArea
                          ? '${area.address}\n반경 ${area.radiusKm.toStringAsFixed(0)}km 안의 새 빵을 알려드려요.'
                          : '키워드 알림은 설정한 지역 3km 안의 매장에서 새 빵이 올라올 때 받을 수 있어요.',
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Color(0xFF64706B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              errorMessage!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE0462E),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBackground,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(hasArea ? '지역 변경' : '관심지역 설정하기'),
                ),
              ),
              if (hasArea) ...[
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: isLoading ? null : onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE0462E),
                    side: const BorderSide(color: Color(0xFFFFCFC6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('삭제'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InterestAreaSetupSheet extends StatefulWidget {
  const _InterestAreaSetupSheet();

  @override
  State<_InterestAreaSetupSheet> createState() =>
      _InterestAreaSetupSheetState();
}

class _InterestAreaSetupSheetState extends State<_InterestAreaSetupSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<GeocodingResult> _results = [];
  bool _isSearching = false;
  bool _isSaving = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final area = context.read<WishlistProvider>().interestArea;
    if (area != null) {
      _searchController.text = area.address;
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
    final value = query.trim();
    if (value.isEmpty) {
      setState(() {
        _results = [];
        _message = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 450), () => _search(value));
  }

  Future<void> _search(String query) async {
    setState(() {
      _isSearching = true;
      _message = null;
    });

    try {
      final results = await NaverGeocodingService.search(query);
      if (!mounted) {
        return;
      }
      setState(() {
        _results = results;
        _isSearching = false;
        if (results.isEmpty) {
          _message = '검색 결과가 없습니다. 도로명이나 지번을 조금 더 자세히 입력해주세요.';
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSearching = false;
        _message = '주소 검색 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      });
    }
  }

  Future<void> _selectResult(GeocodingResult result) async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
      _message = null;
    });

    try {
      await context.read<WishlistProvider>().saveInterestArea(
        name: _areaName(result),
        address: result.displayAddress,
        latitude: result.latitude,
        longitude: result.longitude,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
        _message = ApiException.messageFrom(e);
      });
    }
  }

  String _areaName(GeocodingResult result) {
    final text = result.displayAddress.trim();
    if (text.length <= 50) {
      return text;
    }
    return text.substring(0, 50);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1E1E1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  '관심지역 설정',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF171717),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '키워드 알림을 받을 기준 지역을 골라주세요. 선택한 위치 반경 3km 안의 매장에서 새 빵이 등록되면 알려드릴게요.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: Color(0xFF6B6259),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  enabled: !_isSaving,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: '동네, 학교, 도로명으로 검색',
                    hintStyle: const TextStyle(color: Color(0xFFB5B5B5)),
                    filled: true,
                    fillColor: const Color(0xFFF8F8F8),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF8B8B8B),
                    ),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(13),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBackground,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (_results.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE6E6E6)),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _results.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        return InkWell(
                          onTap: _isSaving ? null : () => _selectResult(result),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 20,
                                  color: AppColors.primaryBackground,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result.displayAddress,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF222222),
                                        ),
                                      ),
                                      if (result.jibunAddress.isNotEmpty &&
                                          result.jibunAddress !=
                                              result.displayAddress) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          result.jibunAddress,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF8A8A8A),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (_message != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _message!,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Color(0xFFE0462E),
                    ),
                  ),
                ],
                if (_isSaving) ...[
                  const SizedBox(height: 18),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
