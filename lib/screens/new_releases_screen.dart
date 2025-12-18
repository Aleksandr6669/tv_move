import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/services/tmdb_service.dart';
import 'package:myapp/widgets/movie_card.dart';

class NewReleasesScreen extends StatefulWidget {
  final TMDbService tmdbService;
  final FocusNode menuFocusNode;

  const NewReleasesScreen(
      {super.key, required this.tmdbService, required this.menuFocusNode});

  @override
  State<NewReleasesScreen> createState() => _NewReleasesScreenState();
}

class _NewReleasesScreenState extends State<NewReleasesScreen> {
  late Future<List<Movie>> _newReleasesFuture;

  @override
  void initState() {
    super.initState();
    _newReleasesFuture = widget.tmdbService.fetchAllMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новинки'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Movie>>(
        future: _newReleasesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет новинок'));
          }

          final movies = snapshot.data!;
          final newReleases =
              movies.where((movie) => movie.category == 'Новинка').toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // 5 карточек в ряду
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: newReleases.length,
            itemBuilder: (context, index) {
              final movie = newReleases[index];
              return Focus(
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    if (index % 5 == 0) {
                      // If it's the first item in a row
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
      ),
    );
  }
}
