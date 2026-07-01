import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'qr_dialog.dart';
import '../../features/add_link/add_link_bottom_sheet.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/link_model.dart';
import '../../providers/link_provider.dart';
import '../../../data/local/hive_service.dart';

class LinkCard extends StatelessWidget {
  final LinkModel link;
  final LinkProvider linkProvider;
  final int? index;

  const LinkCard({
    super.key,
    required this.link,
    required this.linkProvider,
    this.index,
  });

  void _triggerHaptic(BuildContext context) {
    try {
      final hiveService = context.read<HiveService>();
      if (hiveService.hapticsEnabled) {
        HapticFeedback.vibrate();
      }
    } catch (_) {}
  }

  Future<void> _handleTap(BuildContext context) async {
    _triggerHaptic(context);
    var urlString = link.url;
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = 'https://$urlString';
    }
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch browser.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch browser.')),
        );
      }
    }
  }

  void _handleLongPress(BuildContext context) {
    _triggerHaptic(context);
    Clipboard.setData(ClipboardData(text: link.url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rich Image Preview Section
          if (link.previewImageUrl != null && link.previewImageUrl!.isNotEmpty)
            InkWell(
              onTap: () => _handleTap(context),
              onLongPress: () => _handleLongPress(context),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: link.previewImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.white10,
                    child: const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentNeonGreen),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Opacity(
                      opacity: 0.5,
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Link Details Section
          // Link Details Section
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _handleTap(context),
                  onLongPress: () => _handleLongPress(context),
                  child: Container(
                    padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: CachedNetworkImage(
                              imageUrl: 'https://www.google.com/s2/favicons?domain=${link.domainName}&sz=128',
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: SizedBox(
                                  width: 14, 
                                  height: 14, 
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentNeonGreen)
                                )
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.link, size: 16, color: AppTheme.accentNeonGreen),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (link.isLocked)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 6),
                                      child: Icon(Icons.lock, size: 14, color: AppTheme.accentNeonGreen),
                                    ),
                                  Expanded(
                                    child: Text(
                                      link.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      link.domainName,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (link.isFavorite)
                                    const Icon(Icons.favorite, size: 14, color: Colors.redAccent),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (index != null)
                ReorderableDragStartListener(
                  index: index!,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 16.0),
                    child: Icon(Icons.drag_handle, color: Colors.white38, size: 20),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 16.0),
                  child: Icon(Icons.drag_handle, color: Colors.white38, size: 20),
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                padding: EdgeInsets.zero,
                color: AppTheme.surfaceColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) async {
                  _triggerHaptic(context);
                  switch (value) {
                    case 'open':
                      _handleTap(context);
                      break;
                    case 'share':
                      Share.share('${link.title}\n${link.url}');
                      break;
                    case 'copy':
                      _handleLongPress(context);
                      break;
                    case 'qr':
                      QrDialog.show(context, link);
                      break;
                    case 'edit':
                      AddLinkBottomSheet.show(context, existingLink: link);
                      break;
                    case 'favorite':
                      final updatedLink = link.copyWith(isFavorite: !link.isFavorite);
                      linkProvider.updateLink(updatedLink);
                      break;
                    case 'lock':
                      final updatedLink = link.copyWith(isLocked: !link.isLocked);
                      linkProvider.updateLink(updatedLink);
                      break;
                    case 'delete':
                      linkProvider.deleteLink(link.id);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'open',
                    child: ListTile(
                      leading: Icon(Icons.open_in_new, color: Colors.white),
                      title: Text('Open', style: TextStyle(color: Colors.white)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'qr',
                    child: ListTile(
                      leading: Icon(Icons.qr_code, color: Colors.white),
                      title: Text('Show QR', style: TextStyle(color: Colors.white)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'share',
                    child: ListTile(
                      leading: Icon(Icons.share, color: Colors.white),
                      title: Text('Share', style: TextStyle(color: Colors.white)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'copy',
                    child: ListTile(
                      leading: Icon(Icons.copy, color: Colors.white),
                      title: Text('Copy Link', style: TextStyle(color: Colors.white)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit, color: Colors.white),
                      title: Text('Edit', style: TextStyle(color: Colors.white)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'favorite',
                    child: ListTile(
                      leading: Icon(link.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                      title: Text(link.isFavorite ? 'Unfavorite' : 'Favorite', style: const TextStyle(color: Colors.white)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'lock',
                    child: ListTile(
                      leading: Icon(link.isLocked ? Icons.lock_open : Icons.lock, color: Colors.white),
                      title: Text(link.isLocked ? 'Unlock' : 'Lock', style: const TextStyle(color: Colors.white)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.redAccent),
                      title: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
