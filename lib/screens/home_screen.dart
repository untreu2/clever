import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clever/services/gemini_service.dart';
import 'package:clever/services/favorite_service.dart';
import 'package:clever/models/movie_item.dart';
import 'package:clever/widgets/movie_card.dart';
import 'package:clever/screens/favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String genre = '';
  bool loading = false;
  List<MovieItem> movies = [];
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _loadMoviesList();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isFabVisible) setState(() => _isFabVisible = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isFabVisible) setState(() => _isFabVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void fetchMovies() async {
    if (genre.trim().isEmpty) return;

    setState(() {
      loading = true;
      movies.clear();
    });

    try {
      final items = await GeminiService.fetchMovies(
        genre: genre.trim(),
        language: 'en',
      );

      final favUrls = await FavoriteService.getFavoriteUrls();

      setState(() {
        movies =
            items
                .map(
                  (item) => MovieItem(
                    title: item.title,
                    description: item.description,
                    url: item.url,
                    quote: item.quote,
                    imageUrl: item.imageUrl,
                    isFavorite: favUrls.contains(item.url),
                  ),
                )
                .toList();
      });

      await _saveMoviesList(movies);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _saveMoviesList(List<MovieItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString('movie_list', encodedList);
  }

  Future<void> _loadMoviesList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('movie_list');
    final favUrls = await FavoriteService.getFavoriteUrls();

    if (jsonString != null) {
      final List decodedList = jsonDecode(jsonString);
      setState(() {
        movies =
            decodedList.map((e) {
              final movie = MovieItem.fromJson(e);
              return MovieItem(
                title: movie.title,
                description: movie.description,
                url: movie.url,
                quote: movie.quote,
                imageUrl: movie.imageUrl,
                isFavorite: favUrls.contains(movie.url),
              );
            }).toList();
      });
    }
  }

  void _onFavoriteChanged() async {
    final favUrls = await FavoriteService.getFavoriteUrls();
    setState(() {
      movies =
          movies.map((movie) {
            return MovieItem(
              title: movie.title,
              description: movie.description,
              url: movie.url,
              quote: movie.quote,
              imageUrl: movie.imageUrl,
              isFavorite: favUrls.contains(movie.url),
            );
          }).toList();
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

  Widget _buildQuoteSection({required String? quote, required String title}) {
    if (title.isEmpty && (quote?.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Clever',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '“${quote ?? 'Here’s something you might like.'}”',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '— $title',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Align(
          alignment: Alignment.topCenter,
          child: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.black),
            tooltip: 'Favorites',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clever',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Type anything you're in the mood for — action, romance, something deep, or just a vibe. Let Clever do the rest.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Align(
          alignment: Alignment.topCenter,
          child: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.black),
            tooltip: 'Favorites',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMovies = movies.isNotEmpty;
    final quote = hasMovies ? movies.first.quote : null;
    final title = hasMovies ? movies.first.title : '';

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 600),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        curve: Curves.easeInOutCubic,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          opacity: _isFabVisible ? 1.0 : 0.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white.withOpacity(0.6),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => genre = val),
                    onSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                      fetchMovies();
                    },
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Search a vibe...',
                      hintStyle: const TextStyle(color: Colors.black45),
                      prefixIcon: const Icon(
                        Icons.auto_awesome,
                        color: Colors.black87,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          fetchMovies();
                        },
                        child: AnimatedScale(
                          scale: genre.isNotEmpty ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.send, color: Colors.black87),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: AnimatedCrossFade(
                firstChild: _buildInfoSection(),
                secondChild:
                    hasMovies
                        ? _buildQuoteSection(quote: quote, title: title)
                        : const SizedBox.shrink(),
                crossFadeState:
                    hasMovies
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 500),
                firstCurve: Curves.easeOut,
                secondCurve: Curves.easeIn,
                sizeCurve: Curves.easeInOut,
              ),
            ),
          ),
          if (loading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => buildShimmerCard(),
                childCount: 6,
              ),
            )
          else if (!hasMovies)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text("")),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => MovieCard(
                  key: ValueKey(movies[index].url),
                  item: movies[index],
                  onFavoriteChanged: _onFavoriteChanged,
                ),
                childCount: movies.length,
              ),
            ),
        ],
      ),
    );
  }
}
