import '../models/link_model.dart';

abstract class LinkRepository {
  Future<void> saveLink(LinkModel link);
  Future<List<LinkModel>> getAllLinks();
  Future<void> updateLink(LinkModel link);
  Future<void> deleteLink(String id);
  Future<LinkModel?> getLinkById(String id);
  Future<List<LinkModel>> searchLinks(String query);
}
