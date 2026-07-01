import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/hive_service.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const RatingDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedStars = 0;
  bool _submitted = false;

  void _handleStarTap(int index) {
    if (_submitted) return;
    setState(() {
      _selectedStars = index;
      _submitted = true;
    });

    if (index >= 4) {
      // High rating - prompt to go to store
    } else {
      // Low rating - say thanks and save state
      _markAsRated();
    }
  }

  void _markAsRated() async {
    final hiveService = context.read<HiveService>();
    await hiveService.setHasRatedApp(true);
  }

  void _markAsDeclined() async {
    final hiveService = context.read<HiveService>();
    await hiveService.setDeclinedRating(true);
    if (mounted) Navigator.pop(context);
  }

  void _remindLater() {
    // We don't save anything, so the counter will trigger again on the next interval
    if (mounted) Navigator.pop(context);
  }

  Future<void> _openPlayStore() async {
    final uri = Uri.parse('https://play.google.com/store/apps/details?id=com.bharatdev.linkora');
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _markAsRated();
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentNeonGreen.withAlpha(20),
              blurRadius: 50,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E1E1E),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentNeonGreen.withAlpha(40),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 60,
                color: AppTheme.accentNeonGreen,
              ),
            ),
            const SizedBox(height: 32),

            // Text
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedStars == 0
                  ? const Column(
                      key: ValueKey(1),
                      children: [
                        Text(
                          'Enjoying Linkora?',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Tap a star to rate it on the store.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white54),
                        ),
                      ],
                    )
                  : _selectedStars >= 4
                      ? const Column(
                          key: ValueKey(2),
                          children: [
                            Text(
                              'Awesome!',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Please help us grow by leaving a review on the Play Store.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.white54),
                            ),
                          ],
                        )
                      : const Column(
                          key: ValueKey(3),
                          children: [
                            Text(
                              'Thank You!',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Your feedback helps us improve Linkora.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.white54),
                            ),
                          ],
                        ),
            ),
            const SizedBox(height: 32),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => _handleStarTap(starIndex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      starIndex <= _selectedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: _selectedStars == starIndex ? 50 : 40,
                      color: starIndex <= _selectedStars ? Colors.amber : Colors.white24,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),

            // Actions
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedStars == 0
                  ? Column(
                      key: const ValueKey(1),
                      children: [
                        TextButton(
                          onPressed: _remindLater,
                          child: const Text('Remind me later', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        ),
                        TextButton(
                          onPressed: _markAsDeclined,
                          child: const Text('Never ask again', style: TextStyle(color: Colors.white38)),
                        ),
                      ],
                    )
                  : _selectedStars >= 4
                      ? Column(
                          key: const ValueKey(2),
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _openPlayStore,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentNeonGreen,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  elevation: 10,
                                  shadowColor: AppTheme.accentNeonGreen.withAlpha(100),
                                ),
                                child: const Text('Rate on Play Store', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                _markAsRated(); // Assume they did it later or don't want to
                                Navigator.pop(context);
                              },
                              child: const Text('No thanks', style: TextStyle(color: Colors.white54)),
                            ),
                          ],
                        )
                      : Column(
                          key: const ValueKey(3),
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white10,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: const Text('Close', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
