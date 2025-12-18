import 'package:dio/dio.dart';
import 'package:myapp/models/movie.dart';
import 'dart:developer' as developer;

class TMDbService {
  final Dio _dio = Dio();
  // ВАЖНО: Используйте свой собственный API ключ. Этот ключ может быть отозван.
  final String _apiKey = '1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d'; // Замените на реальный ключ API
  final String _baseUrl = 'https://api.themoviedb.org/3';

  TMDbService() {
    // Попытка получить ключ из переменных окружения (лучшая практика)
    // const apiKeyFromEnv = String.fromEnvironment('TMDB_API_KEY');
    // if (apiKeyFromEnv.isNotEmpty) {
    //   _apiKey = apiKeyFromEnv;
    // }

    if (_apiKey == '1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d') {
         developer.log(
            'ПРЕДУПРЕЖДЕНИЕ: Используется ключ API по умолчанию. Пожалуйста, замените его на свой собственный в lib/services/tmdb_service.dart',
            name: 'TMDbService',
            level: 900, // WARNING
        );
    }
  }

  Future<List<Movie>> fetchAllMovies() async {
    developer.log('Начало загрузки всех фильмов из TMDb...', name: 'TMDbService');
    try {
      final List<Movie> allMovies = [];

      // Загрузка популярных фильмов
      allMovies.addAll(await _fetchMovies('/movie/popular', 'Новинка'));

      // Загрузка фильмов с высоким рейтингом
      allMovies.addAll(await _fetchMovies('/movie/top_rated', 'Фильм'));

      // Загрузка популярных сериалов
      allMovies.addAll(await _fetchMovies('/tv/popular', 'Сериал'));

      // Загрузка популярных мультфильмов (используем жанр "Animation")
      allMovies.addAll(await _fetchMoviesWithGenre('/discover/movie', 16, 'Мультфильм'));
      
      // Загрузка аниме (используем жанры "Animation" и "Action & Adventure" и японский язык)
      allMovies.addAll(await _fetchAnime('/discover/tv', 'Аниме'));

      developer.log('Загружено ${allMovies.length} записей из TMDb.', name: 'TMDbService');
      return allMovies;
    } catch (e) {
      developer.log('Ошибка при загрузке данных из TMDb: $e', name: 'TMDbService', level: 1000);
      return [];
    }
  }

  Future<List<Movie>> _fetchMovies(String endpoint, String category) async {
    final response = await _dio.get('$_baseUrl$endpoint', queryParameters: {
      'api_key': _apiKey,
      'language': 'ru-RU',
      'page': 1,
    });
    final results = response.data['results'] as List;
    final movies = results.map((data) => Movie.fromTMDb(data, category)).toList();
    return movies;
  }

  Future<List<Movie>> _fetchMoviesWithGenre(String endpoint, int genreId, String category) async {
    final response = await _dio.get('$_baseUrl$endpoint', queryParameters: {
      'api_key': _apiKey,
      'language': 'ru-RU',
      'sort_by': 'popularity.desc',
      'with_genres': genreId,
      'page': 1,
    });
    final results = response.data['results'] as List;
    final movies = results.map((data) => Movie.fromTMDb(data, category)).toList();
    return movies;
  }

   Future<List<Movie>> _fetchAnime(String endpoint, String category) async {
    final response = await _dio.get('$_baseUrl$endpoint', queryParameters: {
      'api_key': _apiKey,
      'language': 'ja-JP', // Ищем на японском
      'with_original_language': 'ja', // Убедимся, что оригинал японский
      'sort_by': 'popularity.desc',
      'with_genres': '16,10759', // Анимация и Приключения
      'page': 1,
    });
    final results = response.data['results'] as List;
    final movies = results.map((data) => Movie.fromTMDb(data, category)).toList();
    return movies;
  }
}
