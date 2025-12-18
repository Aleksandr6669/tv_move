import 'package:flutter/material.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/screens/movie_details_screen.dart';
import 'package:myapp/services/tmdb_service.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final TMDbService tmdbService;

  const MovieCard({super.key, required this.movie, required this.tmdbService});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _isFocused = false;

  void _navigateToDetails() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MovieDetailsScreen(
        movieId: widget.movie.tmdbId,
        category: widget.movie.category,
        tmdbService: widget.tmdbService,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToDetails,
      child: FocusableActionDetector(
        onFocusChange: (isFocused) {
          if (mounted) {
            setState(() {
              _isFocused = isFocused;
            });
          }
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) => _navigateToDetails(),
          ),
        },
        child: SizedBox(
          width: 150, // Fixed width for each card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Movie Poster
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(widget.movie.posterUrl),
                          fit: BoxFit.cover,
                        ),
                        border: _isFocused
                            ? Border.all(color: Colors.green, width: 3)
                            : null,
                      ),
                    ),
                    // Rating badge
                    if (widget.movie.rating > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.movie.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Movie Title
              Text(
                widget.movie.title,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Year
              Text(
                widget.movie.year.toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
