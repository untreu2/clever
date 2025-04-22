import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _key = 'favorite_movies';

  static Future<List<String>> getFavoriteUrls() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> toggleFavorite(String url, bool isFavorite) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];

    if (isFavorite && !current.contains(url)) {
      current.add(url);
    } else if (!isFavorite && current.contains(url)) {
      current.remove(url);
    }

    await prefs.setStringList(_key, current);
  }

  static Future<bool> isFavorite(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    return current.contains(url);
  }
}
