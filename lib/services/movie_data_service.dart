import 'package:myapp/models/movie.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/services/tmdb_service.dart';
import 'dart:developer' as developer;

class MovieDataService {
  final FirestoreService firestoreService;
  final TMDbService _tmdbService = TMDbService();

  MovieDataService({required this.firestoreService});

  Future<List<Movie>> loadMovies() async {
    developer.log('Проверка наличия фильмов в Firestore...', name: 'MovieDataService');
    final hasMovies = await firestoreService.hasMovies();

    if (hasMovies) {
      developer.log('Фильмы найдены в Firestore, загрузка...', name: 'MovieDataService');
      return await firestoreService.getAllMovies();
    } else {
      developer.log('Фильмы в Firestore не найдены. Загрузка из TMDb...', name: 'MovieDataService');
      final tmdbMovies = await _tmdbService.fetchAllMovies();
      if (tmdbMovies.isNotEmpty) {
        developer.log('Очистка старых данных перед добавлением новых...', name: 'MovieDataService');
        await firestoreService.deleteAllMovies(); // <-- Исправлено
        developer.log('Добавление ${tmdbMovies.length} новых фильмов в Firestore...', name: 'MovieDataService');
        await firestoreService.addMovies(tmdbMovies);
      } else {
        developer.log('Не удалось загрузить фильмы из TMDb.', name: 'MovieDataService', level: 900);
      }
      return tmdbMovies;
    }
  }
}
