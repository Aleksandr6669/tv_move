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
    _loadMoviesFuture = widget.firestoreService.getAllMovies();
  }

  void _deleteMovie(String id) async {
    await widget.firestoreService.deleteMovie(id);
    setState(() {
      _loadMoviesFuture = widget.firestoreService.getAllMovies();
    });
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
          child: ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return ListTile(
                leading: Image.network(movie.posterUrl, width: 50, fit: BoxFit.cover),
                title: Text(movie.title),
                subtitle: Text('${movie.category} - ${movie.year}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteMovie(movie.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
