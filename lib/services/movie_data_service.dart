import 'package:myapp/models/movie.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/services/tmdb_service.dart';
import 'dart:developer' as developer;

class MovieDataService {
  final FirestoreService firestoreService;
  final TMDbService _tmdbService = TMDbService(); // Создаем экземпляр TMDbService

  MovieDataService({required this.firestoreService});

  Future<List<Movie>> loadMovies() async {
    developer.log('Запуск loadMovies...', name: 'MovieDataService');
    try {
      // Сначала попробуем загрузить фильмы из категории 'Новинка'.
      List<Movie> movies = await firestoreService.getMoviesByCategory('Новинка');

      // Если в 'Новинках' ничего нет, значит база, скорее всего, пуста.
      if (movies.isEmpty) {
        developer.log('База данных пуста. Загрузка данных из TMDb...', name: 'MovieDataService');

        // Очищаем на всякий случай, чтобы избежать дублей при повторном сбое
        await firestoreService.clearAllMovies();

        // Загружаем данные из TMDb
        final tmdbMovies = await _tmdbService.fetchAllMovies();
        
        // Сохраняем их в Firestore
        await firestoreService.addMovies(tmdbMovies);

        // Повторно загружаем уже из Firestore, чтобы источник данных был один
        movies = await firestoreService.getMoviesByCategory('Новинка');
        developer.log('Данные из TMDb успешно загружены в Firestore.', name: 'MovieDataService');
      } else {
        developer.log('База данных уже содержит данные. Загрузка пропущена.', name: 'MovieDataService');
      }
      return movies;
    } catch (e, stacktrace) {
      developer.log(
        'Произошла ошибка в loadMovies: $e',
        stackTrace: stacktrace,
        name: 'MovieDataService',
        level: 1000, // SEVERE
      );
      // В случае ошибки возвращаем пустой список, чтобы приложение не падало.
      return [];
    }
  }
}
