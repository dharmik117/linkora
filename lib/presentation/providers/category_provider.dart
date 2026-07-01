import 'package:flutter/material.dart';
import '../../domain/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _categoryRepository;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  CategoryProvider(this._categoryRepository) {
    _loadCategories();
  }

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> _loadCategories() async {
    _isLoading = true;
    notifyListeners();

    _categories = await _categoryRepository.getAllCategories();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _categoryRepository.saveCategory(category);
    await _loadCategories();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _categoryRepository.updateCategory(category);
    await _loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _categoryRepository.deleteCategory(id);
    await _loadCategories();
  }
}
