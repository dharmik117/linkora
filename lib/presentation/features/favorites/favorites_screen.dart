import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/link_provider.dart';
import '../../shared/widgets/link_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final linkProvider = context.watch<LinkProvider>();
    final favoriteLinks = linkProvider.links.where((l) => l.isFavorite && !l.isLocked).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: favoriteLinks.isEmpty
            ? const Center(
                child: Text(
                  'No favorite links yet.\nTap the heart icon on a link to add it here!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.only(top: 16, bottom: 100),
                itemCount: favoriteLinks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final link = favoriteLinks[index];
                  return LinkCard(link: link, linkProvider: linkProvider);
                },
              ),
      ),
    );
  }
}
