import 'package:flutter/material.dart';
import 'package:myapp/models/movie.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              movie.posterUrl,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),
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
      ),
    );
  }
}
