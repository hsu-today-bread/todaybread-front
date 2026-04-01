import 'package:json_annotation/json_annotation.dart';

part 'bread_success_response.g.dart';

@JsonSerializable()
class BreadSuccessResponse {
  final bool success;

  BreadSuccessResponse({required this.success});

  factory BreadSuccessResponse.fromJson(Map<String, dynamic> json) =>
      _$BreadSuccessResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BreadSuccessResponseToJson(this);
}
