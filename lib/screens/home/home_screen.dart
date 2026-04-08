import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:todaybread/models/bread/nearyby_bread_response.dart';
import 'package:todaybread/screens/bread/bread_detail_screen.dart';
import 'package:todaybread/screens/cart/cart_screen.dart';
import 'package:todaybread/services/bread/bread_service.dart';
import 'package:todaybread/utils/display_helper.dart';
import 'package:todaybread/widgets/bread_list_card.dart';

import '../../services/network/api_exception.dart';
import '../../utils/app_colors.dart';

/// 메인 홈 화면 (HomeScreen)
///
/// - 상단 앱바: 앱 타이틀, 알림 아이콘, 장바구니 아이콘
/// - 검색창 + 필터 버튼
/// - 정렬 탭: 전체 / 거리순 / 가격순 / 할인순
/// - 상품 카드 리스트 (스크롤뷰)
/// - 하단 네비게이션바: 홈 / 지도로 보기 / 빵 / MY
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BreadService _breadService = BreadService.instance;
  Timer? _clockTimer;

  /// 현재 선택된 정렬 탭 인덱스
  int _selectedSortIndex = 0;

  /// 정렬 탭 라벨 목록
  final List<String> _sortLabels = ['전체', '거리순', '가격순', '할인순'];

  /// 필터 거리 슬라이더 값 (0.0 ~ 1.0)
  /// 0.0 = 근처(1km), 0.5 = 5km, 1.0 = 10km 이상(멀리)
  double _distanceFilter = 0.0;

  /// 거리 슬라이더 눈금 라벨 목록
  final List<String> _distanceLabels = ['3km', '5km', '10km'];

  List<NearbyBreadResponse> _items = [];
  bool _isLoadingItems = false;
  bool _hasLoadedItems = false;
  String? _loadError;
  double? _currentLatitude;
  double? _currentLongitude;

  @override
  void initState() {
    super.initState();
    _startClockTimer();
    _fetchNearbyItems();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// 상태바 아이콘 색상 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,

      /// 상단 앱바
      appBar: _buildAppBar(),

      body: Column(
        children: [
          /// 민트 배경의 검색창 영역
          _buildSearchSection(),

          /// 정렬 탭 + 상품 리스트
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  /// 상단 앱바 빌드
  ///
  /// - 좌측: 앱 타이틀 '오늘의 빵'
  /// - 우측: 알림 아이콘, 장바구니 아이콘
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        '오늘의 빵',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      actions: [
        /// 알림 아이콘 버튼
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none,
            color: Colors.white,
            size: 26,
          ),
        ),

        /// 장바구니 아이콘 버튼
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
          icon: const Icon(
            Icons.shopping_cart_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
      ],
    );
  }

  /// 검색창 + 필터 버튼 영역 빌드
  ///
  /// - 민트색 배경에 흰색 둥근 검색창
  /// - 우측에 필터 아이콘 버튼
  Widget _buildSearchSection() {
    return Container(
      color: AppColors.primaryBackground,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          /// 검색창
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: '',
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 22),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          /// 필터 버튼
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3D3D3D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _showFilterBottomSheet,
              icon: const Icon(Icons.tune, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  void _startClockTimer() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  /// 정렬 탭 + 상품 리스트 빌드
  Widget _buildContent() {
    return Column(
      children: [
        _buildSortTabs(),
        const SizedBox(height: 8),
        Expanded(child: _buildContentBody()),
      ],
    );
  }

  Widget _buildContentBody() {
    if (_isLoadingItems && !_hasLoadedItems) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null && _items.isEmpty) {
      return _buildMessageState(
        message: _loadError!,
        actionLabel: '다시 시도',
        onPressed: _fetchNearbyItems,
      );
    }

    if (_hasLoadedItems && _items.isEmpty) {
      return _buildMessageState(
        message: '현재 위치 기준으로 표시할 상품이 없습니다.',
        actionLabel: '새로고침',
        onPressed: _fetchNearbyItems,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(_items[index]);
      },
    );
  }

  /// 정렬 탭 행 빌드
  ///
  /// - 전체 / 거리순 / 가격순 / 할인순
  /// - 선택된 탭은 어두운 배경, 나머지는 흰 배경 + 테두리
  Widget _buildSortTabs() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: List.generate(_sortLabels.length, (index) {
            final bool isSelected = _selectedSortIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSortIndex = index;
                  });
                  _fetchNearbyItems();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3D3D3D) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF3D3D3D)
                          : const Color(0xFFDDDDDD),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _sortLabels[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// 개별 상품 카드 빌드
  ///
  /// - 좌측: 상품 이미지 (현재 컬러 박스로 대체)
  /// - 우측: 상품명, 거리, 별점, 가격(할인가/원가), 남은 시간
  Widget _buildItemCard(NearbyBreadResponse item) {
    return BreadListCard(
      name: item.name,
      imageUrl: item.imageUrl,
      distanceText: DisplayHelper.formatDistanceKm(item.distance),
      salePrice: item.salePrice,
      originalPrice: item.originalPrice,
      remainingTimeText: _buildRemainingTime(item),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                BreadDetailScreen(breadId: item.id, storeId: item.storeId),
          ),
        );
      },
    );
  }

  /// 필터 바텀시트 표시
  ///
  /// - 배경 딤처리(barrierColor) 적용
  /// - 거리 슬라이더로 표시 범위 조절
  /// - 적용 버튼으로 설정값 저장 후 닫기
  void _showFilterBottomSheet() {
    /// 바텀시트 내부에서 슬라이더 상태를 독립적으로 관리하기 위한 임시 값
    double tempDistance = _distanceFilter;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,

      /// 배경 딤처리 색상
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 바텀시트 상단 핸들바
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 안내 텍스트
                  const Center(
                    child: Text(
                      '표시될 가게의 거리를 조절해주세요',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// 슬라이더 영역: 근처 ←→ 멀리 레이블 + 슬라이더
                  Row(
                    children: [
                      /// 근처 레이블
                      const Text(
                        '근처',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),

                      /// 거리 슬라이더
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.black87,
                            inactiveTrackColor: Colors.grey.shade300,
                            thumbColor: Colors.black87,
                            overlayColor: Colors.black12,
                            trackHeight: 3,
                          ),
                          child: Slider(
                            value: tempDistance,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (value) {
                              setModalState(() {
                                tempDistance = value;
                              });
                            },
                          ),
                        ),
                      ),

                      /// 멀리 레이블
                      const Text(
                        '멀리',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),

                  /// 거리 눈금 라벨 행 (3km / 5km / 10km)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _distanceLabels.map((label) {
                        return Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// 적용 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        /// 선택한 거리 값을 HomeScreen 상태에 반영
                        setState(() {
                          _distanceFilter = tempDistance;
                        });
                        Navigator.pop(context);
                        _fetchNearbyItems();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '적용',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageState({
    required String message,
    required String actionLabel,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5E5E5E),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBackground,
                side: const BorderSide(color: AppColors.primaryBackground),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchNearbyItems() async {
    setState(() {
      _isLoadingItems = true;
      _loadError = null;
    });

    try {
      final coordinates = await _ensureCoordinates();
      final response = await _breadService.getNearbyBreads(
        lat: coordinates.lat,
        lng: coordinates.lng,
        radius: _selectedRadiusKm,
        sort: _selectedSortQuery,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _items = response;
        _hasLoadedItems = true;
        _isLoadingItems = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _items = [];
        _hasLoadedItems = true;
        _isLoadingItems = false;
        _loadError = _messageFrom(error);
      });
    }
  }

  Future<({double lat, double lng})> _ensureCoordinates() async {
    if (_currentLatitude != null && _currentLongitude != null) {
      return (lat: _currentLatitude!, lng: _currentLongitude!);
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스를 켜주세요.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한을 허용해야 근처 상품을 불러올 수 있습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
    }

    final position = await Geolocator.getCurrentPosition();
    _currentLatitude = position.latitude;
    _currentLongitude = position.longitude;
    return (lat: position.latitude, lng: position.longitude);
  }

  int get _selectedRadiusKm {
    if (_distanceFilter < 0.34) {
      return 3;
    }
    if (_distanceFilter < 0.67) {
      return 5;
    }
    return 10;
  }

  String get _selectedSortQuery {
    switch (_selectedSortIndex) {
      case 1:
        return 'distance';
      case 2:
        return 'price';
      case 3:
        return 'discount';
      default:
        return 'none';
    }
  }

  String _buildRemainingTime(NearbyBreadResponse item) {
    return DisplayHelper.buildLastOrderRemainingTimeText(
      isSelling: item.isSelling,
      lastOrderTime: item.lastOrderTime,
    );
  }

  String _messageFrom(Object error) {
    if (error is Exception) {
      final raw = error.toString();
      if (raw.startsWith('Exception: ')) {
        return raw.replaceFirst('Exception: ', '');
      }
    }
    return ApiException.messageFrom(error);
  }
}
