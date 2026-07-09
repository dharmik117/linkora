import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/hive_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hapticsEnabled = true;
  String _appVersion = 'v1.0.0';

  @override
  void initState() {
    super.initState();
    // Load initial haptic preference
    final hiveService = context.read<HiveService>();
    _hapticsEnabled = hiveService.hapticsEnabled;
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = 'v${info.version}';
        });
      }
    } catch (_) {}
  }

  void _triggerHaptic() {
    if (_hapticsEnabled) {
      HapticFeedback.vibrate();
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hiveService = context.read<HiveService>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // App Preferences Group
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8, top: 16),
            child: Text(
              'PREFERENCES',
              style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
          Material(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  activeColor: AppTheme.accentNeonGreen,
                  title: const Text('Haptic Feedback', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Vibrate on taps and interactions', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  secondary: const Icon(Icons.vibration, color: Colors.white70),
                  value: _hapticsEnabled,
                  onChanged: (bool value) async {
                    setState(() => _hapticsEnabled = value);
                    await hiveService.setHapticsEnabled(value);
                    if (value) {
                      HapticFeedback.vibrate();
                    }
                  },
                ),
              ],
            ),
          ),
          
          // About Group
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8, top: 32),
            child: Text(
              'ABOUT',
              style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
          Material(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.share, color: Colors.white70),
                  title: const Text('Share App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onTap: () {
                    _triggerHaptic();
                    Share.share('Check out Linksy - The best way to securely save and share your links! Available now.');
                  },
                ),
                const Divider(color: Colors.white10, height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.star_rate_rounded, color: Colors.amber),
                  title: const Text('Rate Us', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onTap: () {
                    _triggerHaptic();
                    _launchUrl('https://play.google.com/store/apps/details?id=com.bharatdev.linkora');
                  },
                ),
                const Divider(color: Colors.white10, height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.code, color: AppTheme.accentNeonGreen),
                  title: const Text('More by Bharat Dev', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onTap: () {
                    _triggerHaptic();
                    _launchUrl('https://play.google.com/store/apps/dev?id=8822723877739580334');
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Linksy $_appVersion\nMade with ❤️ by Bharat Dev',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
          const SizedBox(height: 100), // Padding for bottom nav bar
        ],
      ),
    );
  }
}
