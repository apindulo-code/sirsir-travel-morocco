import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class TravelNewsItem {
  const TravelNewsItem({
    required this.title,
    required this.url,
    required this.source,
  });

  final String title;
  final String url;
  final String source;
}

/// Reads headline metadata from Google News RSS and links readers to publishers.
/// The app never republishes full articles or treats headlines as official alerts.
class TravelNewsService {
  Future<List<TravelNewsItem>> fetchLatest({String language = 'ar'}) async {
    final settings = switch (language) {
      'fr' => ('Maroc tourisme transport voyage', 'fr'),
      'en' => ('Morocco tourism travel transport', 'en'),
      'es' => ('Marruecos turismo viajes transporte', 'es'),
      _ => ('المغرب سياحة سفر نقل', 'ar'),
    };
    final locale = settings.$2;
    final uri = Uri.https('news.google.com', '/rss/search', {
      'q': settings.$1,
      'hl': locale,
      'gl': 'MA',
      'ceid': 'MA:$locale',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 18));
    if (response.statusCode != 200) {
      throw Exception('News feed returned HTTP ${response.statusCode}');
    }

    final document = XmlDocument.parse(response.body);
    final items = <TravelNewsItem>[];
    for (final node in document.findAllElements('item').take(12)) {
      final title = node.getElement('title')?.innerText.trim() ?? '';
      final link = node.getElement('link')?.innerText.trim() ?? '';
      final source = node.getElement('source')?.innerText.trim() ?? 'Google News';
      if (title.isEmpty || !link.startsWith('http')) continue;
      items.add(TravelNewsItem(title: title, url: link, source: source));
    }
    return items;
  }
}
