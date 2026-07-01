import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/link_model.dart';
import '../../domain/models/category_model.dart';

class HiveService {
  static const String _encryptionKey = 'hive_encryption_key';
  static const String linkBoxName = 'linksBox';
  static const String categoryBoxName = 'categoryBox';
  static const String settingsBoxName = 'settingsBox';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(LinkModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());

    // Setup Encryption
    String? keyString = await _secureStorage.read(key: _encryptionKey);
    List<int> encryptionKeyAsUint8List;

    if (keyString == null) {
      final key = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _encryptionKey,
        value: base64UrlEncode(key),
      );
      encryptionKeyAsUint8List = key;
    } else {
      encryptionKeyAsUint8List = base64Url.decode(keyString);
    }

    // Open Encrypted Boxes
    await Hive.openBox<LinkModel>(
      linkBoxName,
      encryptionCipher: HiveAesCipher(encryptionKeyAsUint8List),
    );
    
    await Hive.openBox<CategoryModel>(
      categoryBoxName,
    );

    // Open Unencrypted Settings Box
    await Hive.openBox(settingsBoxName);
  }

  bool get hasSeenOnboarding {
    final box = Hive.box(settingsBoxName);
    return box.get('has_seen_onboarding', defaultValue: false);
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    final box = Hive.box(settingsBoxName);
    await box.put('has_seen_onboarding', value);
  }

  bool get hapticsEnabled {
    final box = Hive.box(settingsBoxName);
    return box.get('haptics_enabled', defaultValue: true);
  }

  Future<void> setHapticsEnabled(bool value) async {
    final box = Hive.box(settingsBoxName);
    await box.put('haptics_enabled', value);
  }

  // Rating State Tracking
  int get linksSavedCount {
    final box = Hive.box(settingsBoxName);
    return box.get('links_saved_count', defaultValue: 0);
  }

  Future<void> incrementLinksSavedCount() async {
    final box = Hive.box(settingsBoxName);
    int current = box.get('links_saved_count', defaultValue: 0);
    await box.put('links_saved_count', current + 1);
  }

  bool get hasRatedApp {
    final box = Hive.box(settingsBoxName);
    return box.get('has_rated_app', defaultValue: false);
  }

  Future<void> setHasRatedApp(bool value) async {
    final box = Hive.box(settingsBoxName);
    await box.put('has_rated_app', value);
  }

  bool get declinedRating {
    final box = Hive.box(settingsBoxName);
    return box.get('declined_rating', defaultValue: false);
  }

  Future<void> setDeclinedRating(bool value) async {
    final box = Hive.box(settingsBoxName);
    await box.put('declined_rating', value);
  }
}
