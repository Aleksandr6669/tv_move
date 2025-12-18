import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/services/firestore_service.dart';

class MovieListScreen extends StatefulWidget {
  final FirestoreService firestoreService;
  final FocusNode menuFocusNode;
  final FocusNode contentFocusNode;

  const MovieListScreen({
    super.key,
    required this.firestoreService,
    required this.menuFocusNode,
    required this.contentFocusNode,
  });

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late Future<List<Movie>> _loadMoviesFuture;

  @override
  void initState() {
    super.initState();
    _loadMoviesFuture = _fetchAllMovies();
  }

  Future<List<Movie>> _fetchAllMovies() async {
    // В FirestoreService нет метода для получения ВСЕХ фильмов, 
    // поэтому мы получаем их по каждой категории и объединяем.
    final categories = ['Новинка', 'Фильм', 'Сериал', 'Мультфильм', 'Аниме'];
    final List<Movie> allMovies = [];
    for (final category in categories) {
      final movies = await widget.firestoreService.getMoviesByCategory(category);
      allMovies.addAll(movies);
    }
    // Удаляем дубликаты, если они есть
    final uniqueMovies = allMovies.toSet().toList();
    return uniqueMovies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        title: const Text('Полный список фильмов и сериалов'),
        backgroundColor: const Color(0xFF2C2C2E),
      ),
      body: FutureBuilder<List<Movie>>(
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

          return ListView.builder(
            focusNode: widget.contentFocusNode, // ИСПОЛЬЗУЕМ contentFocusNode
            itemCount: movies.length,
            itemBuilder: (context, index) {
                final movie = movies[index];
                return Focus(
                    onKey: (node, event) {
                        if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                            widget.menuFocusNode.requestFocus();
                            return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                    },
                    child: ListTile(
                        leading: Image.network(movie.posterUrl, width: 50, fit: BoxFit.cover),
                        title: Text(movie.title, style: const TextStyle(color: Colors.white)),
                        subtitle: Text(movie.category, style: const TextStyle(color: Colors.white70)),
                    ),
                );
            },
          );
        },
      ),
    );
  }
}
