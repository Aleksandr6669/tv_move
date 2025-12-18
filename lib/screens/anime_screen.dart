import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/services/tmdb_service.dart';
import 'package:myapp/widgets/movie_card.dart';

class AnimeScreen extends StatefulWidget {
  final TMDbService tmdbService;
  final FocusNode menuFocusNode;

  const AnimeScreen({
    super.key,
    required this.tmdbService,
    required this.menuFocusNode,
  });

  @override
  State<AnimeScreen> createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<AnimeScreen> {
  late Future<List<Movie>> _loadMoviesFuture;

  @override
  void initState() {
    super.initState();
    _loadMoviesFuture = widget.tmdbService.fetchAllMovies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      future: _loadMoviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }
        final movies = snapshot.data ?? [];
        final animeMovies = movies.where((movie) => movie.category == 'Аниме').toList();
        if (animeMovies.isEmpty) {
          return const Center(child: Text('Нет данных'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(24.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, // Set a cross-axis count
            childAspectRatio: 0.65,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: animeMovies.length,
          itemBuilder: (context, index) {
            final movie = animeMovies[index];
            return Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  if (index % 5 == 0) {
                    widget.menuFocusNode.requestFocus();
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: MovieCard(movie: movie, tmdbService: widget.tmdbService),
            );
          },
        );
      },
    );
  }
}
