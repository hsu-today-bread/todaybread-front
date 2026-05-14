import 'package:json_annotation/json_annotation.dart';

part 'boss_response.g.dart';

/// 사업자 인증 응답 DTO입니다.
@JsonSerializable()
class BossResponse {
  /// 사업자 인증 성공 여부입니다.
  final bool success;

  /// 사업자 권한이 반영된 access token입니다.
  final String? accessToken;

  /// access token 만료 시 재발급에 사용하는 refresh token입니다.
  final String? refreshToken;

  /// 사용자에게 보여줄 결과 메시지입니다.
  final String message;

  /// 사업자 인증 응답 모델을 생성합니다.
  BossResponse({
    required this.success,
    required this.message,
    this.accessToken,
    this.refreshToken,
  });

  /// JSON 맵을 [BossResponse]로 변환합니다.
  factory BossResponse.fromJson(Map<String, dynamic> json) =>
      _$BossResponseFromJson(json);

  /// 현재 객체를 JSON 맵으로 변환합니다.
  Map<String, dynamic> toJson() => _$BossResponseToJson(this);
}
