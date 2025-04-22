import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie_item.dart';

class MovieCard extends StatelessWidget {
  final MovieItem item;

  const MovieCard({super.key, required this.item});

  Future<void> _launchUrl() async {
    final uri = Uri.parse(item.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch ${item.url}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _launchUrl,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image:
                      item.imageUrl != null
                          ? DecorationImage(
                            image: CachedNetworkImageProvider(item.imageUrl!),
                            fit: BoxFit.cover,
                          )
                          : null,
                  color: Colors.black87,
                  borderRadius: BorderRadius.zero,
                ),
                height: 180,
              ),

              Container(
                width: double.infinity,
                height: 180,
                color: Colors.black.withOpacity(0.8),
              ),

              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        Uri.parse(item.url).host,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 0.5, thickness: 0.5, color: Colors.black12),
      ],
    );
  }
}
