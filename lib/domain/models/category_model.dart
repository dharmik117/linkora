import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue; // To store a custom color for the category chip

  CategoryModel({
    required this.id,
    required this.name,
    this.colorValue = 0xFF00FF66, // Default to neon green
  });
}
