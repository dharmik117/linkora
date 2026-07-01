import 'package:hive/hive.dart';

part 'link_model.g.dart';

@HiveType(typeId: 0)
class LinkModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String url;

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;

  @HiveField(4)
  String? previewImageUrl;

  @HiveField(5)
  String? faviconUrl;

  @HiveField(6)
  String domainName;

  @HiveField(7)
  String? categoryId;

  @HiveField(8)
  bool isFavorite;

  @HiveField(9)
  bool isLocked;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime lastOpenedAt;

  @HiveField(12)
  int openCount;

  @HiveField(13, defaultValue: 0)
  int orderIndex;

  LinkModel({
    required this.id,
    required this.url,
    required this.title,
    required this.description,
    this.previewImageUrl,
    this.faviconUrl,
    required this.domainName,
    this.categoryId,
    this.isFavorite = false,
    this.isLocked = false,
    required this.createdAt,
    required this.lastOpenedAt,
    this.openCount = 0,
    this.orderIndex = 0,
  });

  LinkModel copyWith({
    String? id,
    String? url,
    String? title,
    String? description,
    String? previewImageUrl,
    String? faviconUrl,
    String? domainName,
    String? categoryId,
    bool? isFavorite,
    bool? isLocked,
    DateTime? createdAt,
    DateTime? lastOpenedAt,
    int? openCount,
    int? orderIndex,
  }) {
    return LinkModel(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      domainName: domainName ?? this.domainName,
      categoryId: categoryId ?? this.categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
      isLocked: isLocked ?? this.isLocked,
      createdAt: createdAt ?? this.createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      openCount: openCount ?? this.openCount,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
