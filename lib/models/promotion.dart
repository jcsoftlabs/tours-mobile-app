import 'package:json_annotation/json_annotation.dart';

part 'promotion.g.dart';

@JsonSerializable()
class Promotion {
  final String id;
  final String title;
  final String description;
  final String? image;
  final double? discount;
  final String? discountType;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  
  // Aliases pour compatibilité
  double? get discountPercentage => discount;
  DateTime get validUntil => endDate;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    this.discount,
    this.discountType,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) =>
      _$PromotionFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionToJson(this);

  bool get isValid {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  String get discountText {
    if (discount == null) return '';
    
    if (discountType == 'percentage') {
      return '-${discount!.toInt()}%';
    } else {
      return '-${discount!.toInt()}€';
    }
  }
}