import 'package:json_annotation/json_annotation.dart';

part 'boss_request.g.dart';

/// 사업자 인증 요청 DTO입니다.
@JsonSerializable()
class BossRequest {
  /// 서버로 전달하는 사업자 등록 번호입니다.
  final String bossNumber;

  BossRequest({required this.bossNumber});

  /// JSON 맵을 [BossRequest]로 변환합니다.
  factory BossRequest.fromJson(Map<String, dynamic> json) =>
      _$BossRequestFromJson(json);

  /// 현재 객체를 JSON 맵으로 변환합니다.
  Map<String, dynamic> toJson() => _$BossRequestToJson(this);
}
