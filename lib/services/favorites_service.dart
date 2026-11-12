import 'package:shared_preferences/shared_preferences.dart';

/// Stores saved tourist-place names locally on this device.
class FavoritesService {
  static const String _key = 'favorite_places';

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? <String>[];
  }

  /// Refreshes the plugin cache from persistent storage after a failed write.
  static Future<List<String>> reloadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getStringList(_key) ?? <String>[];
  }

  static Future<bool> toggleFavorite(String placeName) async {
    final normalizedName = placeName.trim();
    if (normalizedName.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_key) ?? <String>[];
    if (favorites.contains(normalizedName)) {
      favorites.remove(normalizedName);
    } else {
      favorites.add(normalizedName);
    }
    return prefs.setStringList(_key, favorites);
  }

  static Future<bool> isFavorite(String placeName) async {
    final favorites = await getFavorites();
    return favorites.contains(placeName.trim());
  }
}
