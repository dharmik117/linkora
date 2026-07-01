import 'package:flutter/material.dart';
import '../../domain/models/link_model.dart';
import '../../domain/repositories/link_repository.dart';

class LinkProvider extends ChangeNotifier {
  final LinkRepository _linkRepository;

  List<LinkModel> _links = [];
  bool _isLoading = false;

  LinkProvider(this._linkRepository) {
    _loadLinks();
  }

  List<LinkModel> get links => _links;
  bool get isLoading => _isLoading;

  Future<void> _loadLinks() async {
    _isLoading = true;
    notifyListeners();

    _links = await _linkRepository.getAllLinks();
    
    // Sort by orderIndex ascending, then newest first
    _links.sort((a, b) {
      final cmp = a.orderIndex.compareTo(b.orderIndex);
      if (cmp != 0) return cmp;
      return b.createdAt.compareTo(a.createdAt);
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addLink(LinkModel link) async {
    // Ensure the new link goes to the top by giving it a lower orderIndex than the current minimum
    int minOrder = 0;
    if (_links.isNotEmpty) {
      minOrder = _links.map((l) => l.orderIndex).reduce((a, b) => a < b ? a : b);
    }
    link.orderIndex = minOrder - 1;
    
    await _linkRepository.saveLink(link);
    await _loadLinks();
  }

  Future<void> updateLink(LinkModel link) async {
    await _linkRepository.updateLink(link);
    await _loadLinks();
  }

  Future<void> deleteLink(String id) async {
    await _linkRepository.deleteLink(id);
    await _loadLinks();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _links.indexWhere((l) => l.id == id);
    if (index != -1) {
      final link = _links[index];
      link.isFavorite = !link.isFavorite;
      await updateLink(link);
    }
  }

  Future<void> toggleVault(String id) async {
    final index = _links.indexWhere((l) => l.id == id);
    if (index != -1) {
      final link = _links[index];
      link.isLocked = !link.isLocked;
      await updateLink(link);
    }
  }

  Future<void> search(String query) async {
    _isLoading = true;
    notifyListeners();

    if (query.isEmpty) {
      _links = await _linkRepository.getAllLinks();
    } else {
      _links = await _linkRepository.searchLinks(query);
    }

    _links.sort((a, b) {
      final cmp = a.orderIndex.compareTo(b.orderIndex);
      if (cmp != 0) return cmp;
      return b.createdAt.compareTo(a.createdAt);
    });
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> reorderLinks(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    // Update local list instantly for smooth UI
    final item = _links.removeAt(oldIndex);
    _links.insert(newIndex, item);
    
    // Reassign indices incrementally
    final futures = <Future>[];
    for (int i = 0; i < _links.length; i++) {
      if (_links[i].orderIndex != i) {
        _links[i].orderIndex = i;
        futures.add(_linkRepository.updateLink(_links[i]));
      }
    }
    
    notifyListeners();
    // Persist in background
    await Future.wait(futures);
  }
}
