import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/widgets/movie_card.dart';

class HomeScreen extends StatefulWidget {
  final FirestoreService firestoreService;
  final FocusNode menuFocusNode;
  final FocusNode contentFocusNode;

  const HomeScreen({
    super.key,
    required this.firestoreService,
    required this.menuFocusNode,
    required this.contentFocusNode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> _loadMoviesFuture;
  static const int _crossAxisCount = 5;

  @override
  void initState() {
    super.initState();
    _loadMoviesFuture = widget.firestoreService.getMoviesByCategory('Новинка');
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
        if (movies.isEmpty) {
          return const Center(child: Text('Нет данных'));
        }

        return Focus(
          focusNode: widget.contentFocusNode,
          child: GridView.builder(
            padding: const EdgeInsets.all(24.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _crossAxisCount,
              childAspectRatio: 0.65,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return Focus(
                onKey: (node, event) {
                  if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    if (index % _crossAxisCount == 0) {
                      widget.menuFocusNode.requestFocus();
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: MovieCard(movie: movies[index]),
              );
            },
          )
        );
      },
    );
  }
}
