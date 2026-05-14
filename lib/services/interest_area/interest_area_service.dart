import 'package:todaybread/models/interest_area/interest_area_response.dart';
import 'package:todaybread/services/network/dio_client.dart';

class InterestAreaService {
  InterestAreaService._();

  static final InterestAreaService instance = InterestAreaService._();

  Future<InterestAreaResponse?> getInterestArea() async {
    final response = await DioClient.instance.get('/api/interest-area');
    final data = response.data as Map<String, dynamic>;
    final area = data['interestArea'];
    if (area == null) {
      return null;
    }
    return InterestAreaResponse.fromJson(area as Map<String, dynamic>);
  }

  Future<InterestAreaResponse> createInterestArea(
    InterestAreaRequest request,
  ) async {
    final response = await DioClient.instance.post(
      '/api/interest-area',
      data: request.toJson(),
    );
    return InterestAreaResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<InterestAreaResponse> updateInterestArea(
    InterestAreaRequest request,
  ) async {
    final response = await DioClient.instance.put(
      '/api/interest-area',
      data: request.toJson(),
    );
    return InterestAreaResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<InterestAreaDeleteResponse> deleteInterestArea() async {
    final response = await DioClient.instance.delete('/api/interest-area');
    return InterestAreaDeleteResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
