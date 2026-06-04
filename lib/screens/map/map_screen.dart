import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:todaybread/models/store/nearby_store_response.dart';
import 'package:todaybread/screens/store/store_detail_screen.dart';
import 'package:todaybread/services/store/store_service.dart';
import 'package:todaybread/utils/display_helper.dart';
import 'package:todaybread/widgets/app_network_image.dart';
import '../../utils/app_colors.dart';
import '../../services/location/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// 위치를 확보하기 전 지도를 먼저 띄우기 위한 기본 카메라 위치(서울 시청).
  /// 실제 위치가 도착하면 카메라를 그쪽으로 이동시킨다.
  static const NCameraPosition _defaultCameraPosition = NCameraPosition(
    target: NLatLng(37.5666, 126.9784),
    zoom: 14,
  );

  NaverMapController? _mapController;

  /// 지도가 준비되기 전에 위치가 먼저 도착한 경우 보관했다가 onMapReady에서 적용한다.
  NLatLng? _pendingCameraTarget;

  /// 위젯으로 직접 색을 입힌 마커 아이콘(틴트가 아닌 실제 색). 한 번 만들어 재사용한다.
  NOverlayImage? _sellingIcon;
  NOverlayImage? _closedIcon;

  List<NearbyStoreResponse> _stores = [];
  bool _loading = true;
  String? _error;
  bool _showSearchHere = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final position = await _getFastPosition();
      if (!mounted) return;
      // 위치가 도착하면 (이미 렌더링 중인) 지도 카메라를 사용자 위치로 이동시킨다.
      _moveCameraTo(NLatLng(position.latitude, position.longitude));
      final stores = await StoreService.instance.getNearbyStores(
        lat: position.latitude,
        lng: position.longitude,
      );
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _loading = false;
      });
      _addMarkers();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<Position> _getFastPosition() async {
    final last = await Geolocator.getLastKnownPosition();
    if (last != null) return last;
    return determinePosition();
  }

  /// 지도 컨트롤러가 준비됐으면 즉시 카메라를 이동하고,
  /// 아직이면 대기시켜 두었다가 onMapReady에서 적용한다.
  void _moveCameraTo(NLatLng target) {
    final controller = _mapController;
    if (controller != null) {
      controller.updateCamera(
        NCameraUpdate.withParams(target: target, zoom: 14),
      );
    } else {
      _pendingCameraTarget = target;
    }
  }

  void _onMapReady(NaverMapController controller) {
    _mapController = controller;
    final pending = _pendingCameraTarget;
    if (pending != null) {
      controller.updateCamera(
        NCameraUpdate.withParams(target: pending, zoom: 14),
      );
      _pendingCameraTarget = null;
    }
    _addMarkers();
  }

  void _onCameraIdle() {
    if (!_showSearchHere && mounted) {
      setState(() => _showSearchHere = true);
    }
  }

  Future<void> _searchAtCurrentPosition() async {
    if (_mapController == null) return;
    setState(() {
      _showSearchHere = false;
      _loading = true;
    });

    final cameraPosition = await _mapController!.getCameraPosition();
    final target = cameraPosition.target;

    try {
      final stores = await StoreService.instance.getNearbyStores(
        lat: target.latitude,
        lng: target.longitude,
      );
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _loading = false;
      });
      await _mapController!.clearOverlays();
      _addMarkers();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// 판매중/판매종료 마커 아이콘을 위젯에서 한 번만 렌더링해 캐싱한다.
  ///
  /// 기본 마커에 iconTintColor를 주면 원본 핀 색과 섞여 의도한 색이 나오지 않으므로,
  /// 색을 직접 입힌 아이콘 위젯을 이미지로 변환해 사용한다.
  Future<void> _ensureMarkerIcons() async {
    if (_sellingIcon != null && _closedIcon != null) return;
    if (!mounted) return;
    const iconSize = Size(44, 44);
    _sellingIcon = await NOverlayImage.fromWidget(
      widget: const Icon(
        Icons.location_on,
        color: Color(0xFF2E7D32), // 판매중: 초록(강조)
        size: 44,
      ),
      size: iconSize,
      context: context,
    );
    if (!mounted) return;
    _closedIcon = await NOverlayImage.fromWidget(
      widget: const Icon(
        Icons.location_on,
        color: Color(0xFF757575), // 판매종료: 진한 회색(비활성)
        size: 44,
      ),
      size: iconSize,
      context: context,
    );
  }

  Future<void> _addMarkers() async {
    if (_mapController == null) return;
    await _ensureMarkerIcons();
    if (!mounted || _mapController == null) return;
    final markers = _stores.map((store) {
      final marker = NMarker(
        id: 'store_${store.storeId}',
        position: NLatLng(store.latitude, store.longitude),
        icon: store.isSelling ? _sellingIcon : _closedIcon,
        caption: store.isSelling
            ? const NOverlayCaption(
                text: '● 판매중',
                textSize: 12,
                color: Color(0xFFE53935),
                haloColor: Colors.white,
              )
            : null,
        captionAligns: const [NAlign.top],
      );
      marker.setOnTapListener((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoreDetailScreen(storeId: store.storeId),
          ),
        );
      });
      return marker;
    }).toSet();
    _mapController!.addOverlayAll(markers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        title: const Text(
          '내 주변 빵집',
          style: TextStyle(
            color: AppColors.onPrimaryBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
              children: [
                NaverMap(
                  options: const NaverMapViewOptions(
                    initialCameraPosition: _defaultCameraPosition,
                    mapType: NMapType.basic,
                    locationButtonEnable: true,
                  ),
                  onMapReady: _onMapReady,
                  onCameraIdle: _onCameraIdle,
                ),
                if (_showSearchHere)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _searchAtCurrentPosition,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh,
                                size: 16,
                                color: AppColors.primaryBackground,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '이 위치에서 검색',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                _BottomSheet(stores: _stores, loading: _loading, error: _error),
              ],
            ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({required this.stores, required this.loading, this.error});

  final List<NearbyStoreResponse> stores;
  final bool loading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.08,
      minChildSize: 0.08,
      maxChildSize: 0.55,
      snap: true,
      snapSizes: const [0.08, 0.55],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 12,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              if (loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      '매장 정보를 불러올 수 없습니다.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              else if (stores.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      '주변에 등록된 매장이 없습니다.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index.isOdd) return const Divider(height: 1);
                      final store = stores[index ~/ 2];
                      return _StoreCard(store: store);
                    }, childCount: stores.length * 2 - 1),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store});

  final NearbyStoreResponse store;

  String _formatDistance(double kilometers) {
    if (kilometers < 1) return '${(kilometers * 1000).toStringAsFixed(0)}m';
    return '${kilometers.toStringAsFixed(1)}km';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoreDetailScreen(storeId: store.storeId),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: AppNetworkImage(
                imageUrl: store.primaryImageUrl,
                fit: BoxFit.cover,
                placeholder: const Icon(
                  Icons.storefront_outlined,
                  color: Color(0xFFBBBBBB),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          store.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: store.isSelling
                              ? AppColors.primaryBackground.withValues(
                                  alpha: 0.12,
                                )
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          store.isSelling ? '판매중' : '판매종료',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: store.isSelling
                                ? AppColors.primaryBackground
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.storeAddressLine1,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF888888),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDistance(store.distance),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '⭐ ${DisplayHelper.formatRating(store.averageRating, store.reviewCount)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }
}
