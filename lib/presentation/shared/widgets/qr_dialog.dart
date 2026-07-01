import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/link_model.dart';

class QrDialog extends StatefulWidget {
  final LinkModel link;

  const QrDialog({super.key, required this.link});

  static void show(BuildContext context, LinkModel link) {
    showDialog(
      context: context,
      builder: (context) => QrDialog(link: link),
    );
  }

  @override
  State<QrDialog> createState() => _QrDialogState();
}

class _QrDialogState extends State<QrDialog> {
  bool _isProcessing = false;

  Future<void> _shareQrCode() async {
    setState(() => _isProcessing = true);
    try {
      final qrValidationResult = QrValidator.validate(
        data: widget.link.url,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode;
        final lightGreen = AppTheme.accentNeonGreen.withAlpha(220); // slightly lighter/softer green
        
        final painter = QrPainter.withQr(
          qr: qrCode!,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.circle,
            color: lightGreen,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.circle,
            color: lightGreen,
          ),
          gapless: true,
        );

        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/qr_${widget.link.id}.png');
        
        final picData = await painter.toImageData(1024, format: ui.ImageByteFormat.png);
        await file.writeAsBytes(picData!.buffer.asUint8List());

        // We use XFile to share the image. The native share sheet includes "Save Image" 
        // options automatically on both iOS and Android.
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/png')],
          text: 'Scan to open: ${widget.link.title}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to process QR Code.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lightGreen = AppTheme.accentNeonGreen.withAlpha(220);

    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.link.title.isNotEmpty ? widget.link.title : widget.link.domainName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              widget.link.url,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: lightGreen, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: lightGreen.withAlpha(80),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: QrImageView(
                data: widget.link.url,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: const Color(0xFF1E1E1E),
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.circle,
                  color: lightGreen,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: lightGreen,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  icon: Icons.share,
                  label: 'Share QR Code',
                  onTap: _shareQrCode,
                  color: lightGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required String label, required VoidCallback onTap, required Color color}) {
    return InkWell(
      onTap: _isProcessing ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
