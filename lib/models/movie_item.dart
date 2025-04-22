import 'package:metadata_fetch/metadata_fetch.dart';

class MovieItem {
  final String title;
  final String description;
  final String url;
  final String? imageUrl;
  final String? quote;

  MovieItem({
    required this.title,
    required this.description,
    required this.url,
    this.imageUrl,
    this.quote,
  });

  factory MovieItem.fromJson(Map<String, dynamic> json) {
    return MovieItem(
      title: json['title'],
      description: json['description'],
      url: json['url'],
      quote: json['quote'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'quote': quote,
      'imageUrl': imageUrl,
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
    );
  }
}
