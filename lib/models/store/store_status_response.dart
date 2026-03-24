import 'package:json_annotation/json_annotation.dart';
import 'package:todaybread/models/store/store_common_response.dart';

part 'store_status_response.g.dart';

/// 사장님 계정의 가게 등록 상태 응답 DTO입니다.
@JsonSerializable()
class StoreStatusResponse {
  final bool hasStore;
  final StoreCommonResponse? storeCommonResponse;

  StoreStatusResponse({required this.hasStore, this.storeCommonResponse});

  factory StoreStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StoreStatusResponseToJson(this);
}
