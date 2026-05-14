import 'package:json_annotation/json_annotation.dart';

part 'boss_request.g.dart';

/// 사업자 인증 요청 DTO입니다.
@JsonSerializable()
class BossRequest {
  /// 서버로 전달하는 사업자 등록 번호입니다. (숫자 10자리)
  final String bossNumber;

  /// 개업일자입니다. (yyyyMMdd 형식)
  final String businessStartDate;

  /// 대표자명입니다.
  final String representativeName;

  BossRequest({
    required this.bossNumber,
    required this.businessStartDate,
    required this.representativeName,
  });

  /// JSON 맵을 [BossRequest]로 변환합니다.
  factory BossRequest.fromJson(Map<String, dynamic> json) =>
      _$BossRequestFromJson(json);

  /// 현재 객체를 JSON 맵으로 변환합니다.
  Map<String, dynamic> toJson() => _$BossRequestToJson(this);
}
