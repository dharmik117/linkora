import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/hive_service.dart';
import '../home/home_screen.dart';
import '../favorites/favorites_screen.dart';
import '../add_link/add_link_bottom_sheet.dart';
import '../vault/vault_screen.dart';
import '../settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _handleSharedText(value.first.path);
      }
    }, onError: (err) {
      debugPrint("getIntentDataStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _handleSharedText(value.first.path);
      }
      ReceiveSharingIntent.instance.reset();
    });
  }

  void _handleSharedText(String text) {
    if (text.isEmpty) return;
    // Basic extraction if they shared text with a URL inside it
    final urlRegex = RegExp(r"(https?:\/\/[^\s]+)");
    final match = urlRegex.firstMatch(text);
    final urlToSave = match != null ? match.group(0) : text;
    
    AddLinkBottomSheet.show(context, initialUrl: urlToSave);
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const FavoritesScreen(),
    const VaultScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          try {
            if (context.read<HiveService>().hapticsEnabled) {
              HapticFeedback.vibrate();
            }
          } catch (_) {}
          AddLinkBottomSheet.show(context);
        },
        child: const Icon(Icons.add, size: 32),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.accentNeonGreen,
            unselectedItemColor: Colors.white54,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: _currentIndex,
            onTap: (index) {
              try {
                final hiveService = context.read<HiveService>();
                if (hiveService.hapticsEnabled) {
                  HapticFeedback.vibrate();
                }
              } catch (_) {}
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
              BottomNavigationBarItem(icon: Icon(Icons.lock_outline), label: 'Vault'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}
