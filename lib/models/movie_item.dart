import 'package:metadata_fetch/metadata_fetch.dart';

class MovieItem {
  final String title;
  final String description;
  final String url;
  final String? quote;
  String? imageUrl;
  bool isFavorite;

  MovieItem({
    required this.title,
    required this.description,
    required this.url,
    this.quote,
    this.imageUrl,
    this.isFavorite = false,
  });

  factory MovieItem.fromJson(Map<String, dynamic> json) {
    return MovieItem(
      title: json['title'],
      description: json['description'],
      url: json['url'],
      quote: json['quote'],
      imageUrl: json['imageUrl'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'quote': quote,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
    };
  }

  static Future<MovieItem> fromJsonWithImage(Map<String, dynamic> json) async {
    final metadata = await MetadataFetch.extract(json['url']);
    return MovieItem(
      title: json['title'],
      description: json['description'],
      url: json['url'],
      quote: json['quote'],
      imageUrl: metadata?.image,
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
