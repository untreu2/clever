import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:clever/models/movie_item.dart';
import 'package:clever/services/favorite_service.dart';
import 'package:clever/widgets/movie_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<MovieItem> favorites = [];
  bool loading = true;
  MovieItem? randomQuoteItem;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final copiedFavorites = await FavoriteService.getFavoriteMovies();

    final quoteItems =
        copiedFavorites
            .where((item) => (item.quote?.isNotEmpty ?? false))
            .toList();

    final randomIndex =
        quoteItems.isNotEmpty ? Random().nextInt(quoteItems.length) : null;

    setState(() {
      favorites = copiedFavorites;
      if (randomIndex != null) {
        randomQuoteItem = quoteItems[randomIndex];
      }
      loading = false;
    });
  }

  Widget buildShimmerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderWithQuote() {
    final hasQuote = randomQuoteItem?.quote?.isNotEmpty ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Favorites',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: -1,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            firstChild: _buildInfoText(),
            secondChild: _buildQuoteSection(),
            crossFadeState:
                hasQuote ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 400),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText() {
    return const Text(
      "Take a look at your favorite movies.",
      style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
    );
  }

  Widget _buildQuoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '“${randomQuoteItem?.quote ?? ''}”',
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '— ${randomQuoteItem?.title ?? ''}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderWithQuote()),
          if (loading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => buildShimmerCard(),
                childCount: 6,
              ),
            )
          else if (favorites.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  "No favorites yet.",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => MovieCard(
                  key: ValueKey(favorites[index].url),
                  item: favorites[index],
                  onFavoriteChanged: _loadFavorites,
                ),
                childCount: favorites.length,
              ),
            ),
        ],
      ),
    );
  }
}
