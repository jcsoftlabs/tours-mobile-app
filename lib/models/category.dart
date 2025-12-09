import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final String id;
  final String name;
  final String icon;
  final String color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  static List<Category> getDefaultCategories() {
    return [
      Category(
        id: 'hotels',
        name: 'Hôtels',
        icon: 'hotel',
        color: '0xFF2196F3',
      ),
      Category(
        id: 'restaurants',
        name: 'Restaurants',
        icon: 'restaurant',
        color: '0xFFFF5722',
      ),
      Category(
        id: 'tourism',
        name: 'Sites Touristiques',
        icon: 'place',
        color: '0xFF4CAF50',
      ),
      Category(
        id: 'events',
        name: 'Évènements',
        icon: 'event',
        color: '0xFF9C27B0',
      ),
    ];
  }
}