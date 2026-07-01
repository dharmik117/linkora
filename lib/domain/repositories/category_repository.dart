import '../models/category_model.dart';

abstract class CategoryRepository {
  Future<void> saveCategory(CategoryModel category);
  Future<List<CategoryModel>> getAllCategories();
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}
