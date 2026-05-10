import 'package:todaybread/models/interest_area/interest_area_response.dart';
import 'package:todaybread/services/network/dio_client.dart';

class InterestAreaService {
  InterestAreaService._();

  static final InterestAreaService instance = InterestAreaService._();

  Future<InterestAreaResponse?> getInterestArea() async {
    final response = await DioClient.instance.get('/api/interest-area');
    final data = response.data as Map<String, dynamic>;
    final areaData = data['interestArea'];
    if (areaData == null) return null;
    return InterestAreaResponse.fromJson(areaData as Map<String, dynamic>);
  }

  Future<InterestAreaResponse> createInterestArea({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    final response = await DioClient.instance.post(
      '/api/interest-area',
      data: {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return InterestAreaResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<InterestAreaResponse> updateInterestArea({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    final response = await DioClient.instance.put(
      '/api/interest-area',
      data: {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return InterestAreaResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<({bool success, bool keywordNotificationDisabled})>
  deleteInterestArea() async {
    final response = await DioClient.instance.delete('/api/interest-area');
    final data = response.data as Map<String, dynamic>;
    return (
      success: data['success'] as bool? ?? false,
      keywordNotificationDisabled:
          data['keywordNotificationDisabled'] as bool? ?? false,
    );
  }
}
