import 'package:metadata_fetch/metadata_fetch.dart';

class MetadataService {
  Future<Metadata?> fetch(String url) async {
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    
    Metadata? data;
    final youtubeId = _extractYoutubeId(url);

    try {
      data = await MetadataFetch.extract(url);
    } catch (e) {
      // Ignore network errors, we will still apply fallbacks below
    }

    if (youtubeId != null) {
      data ??= Metadata();
      if (data.image == null || data.image!.isEmpty) {
        data.image = 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';
      }
      if (data.title == null || data.title!.isEmpty) {
        data.title = 'YouTube Video';
      }
    }

    return data;
  }

  String? _extractYoutubeId(String url) {
    RegExp regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  String extractDomain(String url) {
    try {
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      return 'Unknown';
    }
  }
}
