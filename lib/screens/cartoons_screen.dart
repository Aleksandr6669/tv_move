import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/services/tmdb_service.dart';
import 'package:myapp/widgets/movie_card.dart';

class CartoonsScreen extends StatefulWidget {
  final TMDbService tmdbService;
  final FocusNode menuFocusNode;

  const CartoonsScreen({
    super.key,
    required this.tmdbService,
    required this.menuFocusNode,
  });

  @override
  State<CartoonsScreen> createState() => _CartoonsScreenState();
}

class _CartoonsScreenState extends State<CartoonsScreen> {
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
        final cartoonMovies = movies.where((movie) => movie.category == 'Мультфильм').toList();
        if (cartoonMovies.isEmpty) {
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
          itemCount: cartoonMovies.length,
          itemBuilder: (context, index) {
            final movie = cartoonMovies[index];
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
