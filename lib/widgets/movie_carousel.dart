import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/services/tmdb_service.dart';
import 'package:myapp/widgets/movie_card.dart';

class MovieCarousel extends StatefulWidget {
  final String title;
  final List<Movie> movies;
  final FocusNode menuFocusNode;
  final TMDbService tmdbService; // Added tmdbService

  const MovieCarousel({
    super.key,
    required this.title,
    required this.movies,
    required this.menuFocusNode,
    required this.tmdbService, // Require tmdbService in constructor
  });

  @override
  State<MovieCarousel> createState() => _MovieCarouselState();
}

class _MovieCarouselState extends State<MovieCarousel> {
  int _focusedIndex = -1;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
        ),
        SizedBox(
          height: 270, // Carousel height
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];

              return Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    if (hasFocus) {
                      _focusedIndex = index;
                      _scrollToIndex(index);
                    } else if (_focusedIndex == index) {
                      _focusedIndex = -1;
                    }
                  });
                },
                 onKeyEvent: (node, event) {
                  if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    if (index == 0) { // If it's the first item
                      widget.menuFocusNode.requestFocus(); // Return focus to the menu
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  // Pass tmdbService to MovieCard
                  child: MovieCard(movie: movie, tmdbService: widget.tmdbService),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _scrollToIndex(int index) {
    double target = index * 160.0; // Card width + padding
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

   @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
