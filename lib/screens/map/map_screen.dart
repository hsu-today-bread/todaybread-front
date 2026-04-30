import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:todaybread/models/store/nearby_store_response.dart';
import 'package:todaybread/screens/store/store_detail_screen.dart';
import 'package:todaybread/services/store/store_service.dart';
import '../../utils/app_colors.dart';
import '../../services/location/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  NCameraPosition? _initialPosition;
  NaverMapController? _mapController;
  List<NearbyStoreResponse> _stores = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final position = await _getFastPosition();
      if (!mounted) return;
      setState(() {
        _initialPosition = NCameraPosition(
          target: NLatLng(position.latitude, position.longitude),
          zoom: 14,
        );
      });
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

  void _onMapReady(NaverMapController controller) {
    _mapController = controller;
    _addMarkers();
  }

  void _addMarkers() {
    if (_mapController == null) return;
    final markers = _stores.map((store) {
      final marker = NMarker(
        id: 'store_${store.storeId}',
        position: NLatLng(store.latitude, store.longitude),
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _initialPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                NaverMap(
                  options: NaverMapViewOptions(
                    activeLayerGroups: [NLayerGroup.building],
                    initialCameraPosition: _initialPosition!,
                    mapType: NMapType.basic,
                    locationButtonEnable: true,
                  ),
                  onMapReady: _onMapReady,
                ),
                _BottomSheet(
                  stores: _stores,
                  loading: _loading,
                  error: _error,
                ),
              ],
            ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({
    required this.stores,
    required this.loading,
    this.error,
  });

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
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index.isOdd) return const Divider(height: 1);
                        final store = stores[index ~/ 2];
                        return _StoreCard(store: store);
                      },
                      childCount: stores.length * 2 - 1,
                    ),
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

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.toStringAsFixed(0)}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
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
              child: store.primaryImageUrl != null
                  ? Image.network(
                      store.primaryImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, e, st) => const Icon(
                        Icons.storefront_outlined,
                        color: Color(0xFFBBBBBB),
                        size: 28,
                      ),
                    )
                  : const Icon(
                      Icons.storefront_outlined,
                      color: Color(0xFFBBBBBB),
                      size: 28,
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
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: store.isSelling
                              ? AppColors.primaryBackground.withValues(alpha: 0.12)
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
                        fontSize: 13, color: Color(0xFF888888)),
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
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }
}
