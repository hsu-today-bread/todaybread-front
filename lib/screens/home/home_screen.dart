import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  /// 현재 선택된 정렬 탭 인덱스
  int _selectedSortIndex = 0;

  /// 현재 선택된 하단 네비게이션 인덱스
  int _selectedNavIndex = 0;

  /// 정렬 탭 라벨 목록
  final List<String> _sortLabels = ['전체', '거리순', '가격순', '할인순'];

  /// 필터 거리 슬라이더 값 (0.0 ~ 1.0)
  /// 0.0 = 근처(1km), 0.5 = 5km, 1.0 = 10km 이상(멀리)
  double _distanceFilter = 0.0;

  /// 거리 슬라이더 눈금 라벨 목록
  final List<String> _distanceLabels = ['3km', '5km', '10km'];

  /// 더미 상품 데이터 목록(서버랑 연동할 때 여기 수정하면 됨)
  final List<Map<String, dynamic>> _items = [
    {
      'name': '파리 바게트 딸기케이크',
      'distance': '0.7km',
      'rating': '4.9',
      'price': 9600,
      'originalPrice': 14500,
      'remainingTime': '08:12:44:28',
      'imagePlaceholder': Colors.brown.shade200,
    },
    {
      'name': '파리 바게트 딸기케이크',
      'distance': '0.7km',
      'rating': '4.9',
      'price': 9600,
      'originalPrice': 14500,
      'remainingTime': '08:12:44:28',
      'imagePlaceholder': Colors.orange.shade200,
    },
    {
      'name': '파리 바게트 딸기케이크',
      'distance': '0.7km',
      'rating': '4.9',
      'price': 9600,
      'originalPrice': 14500,
      'remainingTime': '08:12:44:28',
      'imagePlaceholder': Colors.blueGrey.shade200,
    },
    {
      'name': '파리 바게트 딸기케이크',
      'distance': '0.7km',
      'rating': '4.9',
      'price': 9600,
      'originalPrice': 14500,
      'remainingTime': '08:12:44:28',
      'imagePlaceholder': Colors.brown.shade200,
    },
    {
      'name': '파리 바게트 딸기케이크',
      'distance': '0.7km',
      'rating': '4.9',
      'price': 9600,
      'originalPrice': 14500,
      'remainingTime': '08:12:44:28',
      'imagePlaceholder': Colors.amber.shade200,
    },
  ];

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
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),

      /// 하단 네비게이션바
      bottomNavigationBar: _buildBottomNavBar(),
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
          onPressed: () {},
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
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 22,
                  ),
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
              icon: const Icon(
                Icons.tune,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 정렬 탭 + 상품 리스트 빌드
  Widget _buildContent() {
    return Column(
      children: [
        /// 정렬 탭 행
        _buildSortTabs(),

        const SizedBox(height: 8),

        /// 상품 카드 스크롤 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return _buildItemCard(_items[index]);
            },
          ),
        ),
      ],
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
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF3D3D3D)
                        : Colors.white,
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
  Widget _buildItemCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// 상품 이미지 영역
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Container(
                width: 120,
                color: item['imagePlaceholder'] as Color,

                /// TODO: 실제 이미지 연동 시 Image.network() 또는 Image.asset()으로 교체
                child: const Center(
                  child: Icon(
                    Icons.bakery_dining,
                    size: 40,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),

            /// 상품 정보 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 상품명
                    Text(
                      item['name'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 4),

                    /// 거리 + 별점 행
                    Row(
                      children: [
                        Text(
                          item['distance'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          item['rating'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// 가격 행: 할인가 + 원가(취소선)
                    Row(
                      children: [
                        Text(
                          '${_formatPrice(item['price'] as int)}원',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_formatPrice(item['originalPrice'] as int)}원',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// 남은 시간 행
                    Row(
                      children: [
                        const Text(
                          '남은시간',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['remainingTime'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 하단 네비게이션바 빌드
  ///
  /// - 홈 / 지도로 보기 / 빵 / MY
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: (index) {
        setState(() {
          _selectedNavIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBackground,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: '지도로 보기',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: '빵',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'MY',
        ),
      ],
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
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
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
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
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
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
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

  /// 가격을 천 단위 콤마 포함 문자열로 변환
  ///
  /// ex) 14500 → '14,500'
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
    );
  }
}