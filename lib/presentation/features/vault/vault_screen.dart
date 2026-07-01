import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/link_provider.dart';
import '../../shared/widgets/link_card.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;

  Future<void> _authenticate() async {
    setState(() => _isAuthenticating = true);
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access your Secret Vault',
      );
      if (mounted) {
        setState(() {
          _isAuthenticated = didAuthenticate;
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isAuthenticating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication failed or is not available on this device.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: AppTheme.accentNeonGreen),
              const SizedBox(height: 24),
              const Text(
                'Secret Vault',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your locked links are hidden here.',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isAuthenticating ? null : _authenticate,
                icon: _isAuthenticating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.fingerprint, color: Colors.black),
                label: const Text(
                  'Unlock Vault',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentNeonGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Authenticated State
    final linkProvider = context.watch<LinkProvider>();
    final lockedLinks = linkProvider.links.where((l) => l.isLocked).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Secret Vault',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_open, color: AppTheme.accentNeonGreen),
            tooltip: 'Lock Vault',
            onPressed: () => setState(() => _isAuthenticated = false),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: lockedLinks.isEmpty
            ? const Center(
                child: Text(
                  'No locked links yet.\nTap the lock icon on a link to move it here!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.only(top: 16, bottom: 100),
                itemCount: lockedLinks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final link = lockedLinks[index];
                  return LinkCard(link: link, linkProvider: linkProvider);
                },
              ),
      ),
    );
  }
}
