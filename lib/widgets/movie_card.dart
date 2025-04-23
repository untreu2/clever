import 'package:clever/services/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie_item.dart';

class MovieCard extends StatefulWidget {
  final MovieItem item;
  final void Function()? onFavoriteChanged;

  const MovieCard({super.key, required this.item, this.onFavoriteChanged});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.item.isFavorite;
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final status = await FavoriteService.isFavorite(widget.item.url);
    setState(() => isFavorite = status);
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.item.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch ${widget.item.url}';
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => isFavorite = !isFavorite);
    await FavoriteService.toggleFavorite(widget.item, isFavorite);
    widget.onFavoriteChanged?.call();
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
                height: 180,
                decoration: BoxDecoration(
                  image:
                      widget.item.imageUrl != null
                          ? DecorationImage(
                            image: CachedNetworkImageProvider(
                              widget.item.imageUrl!,
                            ),
                            fit: BoxFit.cover,
                          )
                          : null,
                  color: Colors.black87,
                ),
              ),
              Container(
                width: double.infinity,
                height: 180,
                color: Colors.black.withOpacity(0.75),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _toggleFavorite,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey<bool>(isFavorite),
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.item.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        Uri.parse(widget.item.url).host,
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
