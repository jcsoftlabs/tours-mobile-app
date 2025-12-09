import 'package:json_annotation/json_annotation.dart';

part 'partner.g.dart';

@JsonSerializable()
class Partner {
  final String id;
  final String name;
  final String email;
  final String phone;

  const Partner({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Partner.fromJson(Map<String, dynamic> json) => _$PartnerFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerToJson(this);
}