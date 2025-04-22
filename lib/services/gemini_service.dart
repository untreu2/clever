import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_item.dart';
import '../constants/api_keys.dart';

class GeminiService {
  static Future<List<MovieItem>> fetchMovies({
    required String genre,
    required String language,
  }) async {
    final prompt = '''
    Give a JSON array of 5 random movie recommendations based on "$genre".

    Each movie must include:
    - "title": the name of the movie and year
    - "description": a short plot summary
    - "url": a reliable external link (IMDb, Letterboxd, etc.)
    - "quote": a memorable quote from the movie without "" signs (English only)

    Respond only in $language.
    Output must be raw JSON only — no markdown, no explanations.
    ''';

    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${ApiKeys.gemini}',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final raw = jsonDecode(response.body);
      String text = raw['candidates'][0]['content']['parts'][0]['text'];

      text = text.trim();
      if (text.startsWith('```json')) {
        text = text.replaceFirst('```json', '').trim();
      } else if (text.startsWith('```')) {
        text = text.replaceFirst('```', '').trim();
      }
      if (text.endsWith('```')) {
        text = text.substring(0, text.length - 3).trim();
      }

      final List parsed = jsonDecode(text);
      return Future.wait(parsed.map((e) => MovieItem.fromJsonWithImage(e)));
    } else {
      throw Exception("Failed to fetch movies: ${response.body}");
    }
  }
}
