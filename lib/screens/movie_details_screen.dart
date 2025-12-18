import 'package:flutter/material.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/services/tmdb_service.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;
  final String category;
  final TMDbService tmdbService;

  const MovieDetailsScreen({
    super.key,
    required this.movieId,
    required this.category,
    required this.tmdbService,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late Future<Movie> _movieDetailsFuture;

  @override
  void initState() {
    super.initState();
    _movieDetailsFuture = widget.tmdbService.fetchMovieDetails(widget.movieId, widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Movie>(
        future: _movieDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Фильм не найден'));
          }

          final movie = snapshot.data!;

          return Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  movie.posterUrl,
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                        Colors.black,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              // Content
              SingleChildScrollView(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: SizedBox(
                    width: 800,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 250,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(movie.posterUrl, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 40),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${movie.year} • ${movie.category}',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    movie.genres.join(', '),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    movie.description,
                                    maxLines: 4, // Limit the number of lines
                                    overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                                    style: TextStyle(
                                      color: Colors.grey[200],
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text('Смотреть'),
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Back Button
              Positioned(
                top: 40,
                left: 40,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Назад'),
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
