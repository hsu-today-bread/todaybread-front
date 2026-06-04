import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/interest_area/interest_area_provider.dart';
import 'package:todaybread/services/geocoding/naver_geocoding_service.dart';
import 'package:todaybread/utils/app_colors.dart';

class InterestAreaSearchScreen extends StatefulWidget {
  const InterestAreaSearchScreen({super.key});

  @override
  State<InterestAreaSearchScreen> createState() =>
      _InterestAreaSearchScreenState();
}

class _InterestAreaSearchScreenState extends State<InterestAreaSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<GeocodingResult> _results = [];
  bool _isSearching = false;
  String? _searchError;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
      _results = [];
    });

    try {
      final results = await NaverGeocodingService.search(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        if (results.isEmpty) {
          _searchError = '검색 결과가 없습니다. 다른 키워드로 검색해보세요.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searchError = '주소 검색에 실패했습니다. 다시 시도해주세요.';
      });
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _selectResult(GeocodingResult result) async {
    final provider = context.read<InterestAreaProvider>();
    final success = await provider.save(
      name: _searchController.text.trim(),
      address: result.displayAddress,
      latitude: result.latitude,
      longitude: result.longitude,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? '관심지역 설정에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<InterestAreaProvider>().isSubmitting;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(false),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF4A3A3A),
            size: 22,
          ),
        ),
        title: const Text(
          '관심지역 설정',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: '장소명 또는 주소를 입력해주세요',
                      hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBackground,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSearching ? null : _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBackground,
                    foregroundColor: AppColors.onPrimaryBackground,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _isSearching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimaryBackground,
                          ),
                        )
                      : const Text('검색'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_searchError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _searchError!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
            ),
          Expanded(
            child: isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Color(0xFFF0F0F0),
                    ),
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primaryBackground,
                        ),
                        title: Text(
                          result.displayAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle:
                            result.roadAddress.isNotEmpty &&
                                result.jibunAddress.isNotEmpty &&
                                result.roadAddress != result.displayAddress
                            ? Text(
                                result.jibunAddress,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF888888),
                                ),
                              )
                            : null,
                        onTap: () => _selectResult(result),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
