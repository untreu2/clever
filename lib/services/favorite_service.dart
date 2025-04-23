import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie_item.dart';

class FavoriteService {
  static const String _key = 'favorite_movies';

  static Future<List<MovieItem>> getFavoriteMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList
        .map((item) => MovieItem.fromJson(json.decode(item)))
        .toList();
  }

  static Future<void> toggleFavorite(MovieItem movie, bool isFavorite) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    final movieJson = json.encode(movie.toJson());
    final updatedList = [...jsonList];

    final index = updatedList.indexWhere((item) {
      final decoded = json.decode(item);
      return decoded['url'] == movie.url;
    });

    if (isFavorite) {
      if (index == -1) updatedList.add(movieJson);
    } else {
      if (index != -1) updatedList.removeAt(index);
    }

    await prefs.setStringList(_key, updatedList);
  }

  static Future<bool> isFavorite(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    return jsonList.any((item) {
      final decoded = json.decode(item);
      return decoded['url'] == url;
    });
  }
}
