import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/link_model.dart';
import '../../domain/repositories/link_repository.dart';
import '../local/hive_service.dart';

class LinkRepositoryImpl implements LinkRepository {
  final Box<LinkModel> _linkBox;

  LinkRepositoryImpl() : _linkBox = Hive.box<LinkModel>(HiveService.linkBoxName);

  @override
  Future<void> saveLink(LinkModel link) async {
    await _linkBox.put(link.id, link);
  }

  @override
  Future<List<LinkModel>> getAllLinks() async {
    return _linkBox.values.toList();
  }

  @override
  Future<void> updateLink(LinkModel link) async {
    await _linkBox.put(link.id, link);
  }

  @override
  Future<void> deleteLink(String id) async {
    await _linkBox.delete(id);
  }

  @override
  Future<LinkModel?> getLinkById(String id) async {
    return _linkBox.get(id);
  }

  @override
  Future<List<LinkModel>> searchLinks(String query) async {
    final lowerQuery = query.toLowerCase();
    return _linkBox.values.where((link) {
      return link.title.toLowerCase().contains(lowerQuery) ||
             link.url.toLowerCase().contains(lowerQuery) ||
             link.description.toLowerCase().contains(lowerQuery) ||
             link.domainName.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
