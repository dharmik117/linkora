import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';
import '../local/hive_service.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final Box<CategoryModel> _categoryBox;

  CategoryRepositoryImpl() : _categoryBox = Hive.box<CategoryModel>(HiveService.categoryBoxName);

  @override
  Future<void> saveCategory(CategoryModel category) async {
    await _categoryBox.put(category.id, category);
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    return _categoryBox.values.toList();
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await _categoryBox.put(category.id, category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _categoryBox.delete(id);
  }
}
