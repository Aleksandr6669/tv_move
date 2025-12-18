import 'dart:async';
import 'package:dio/dio.dart';
import 'package:myapp/models/movie.dart';
import 'dart:developer' as developer;

class TMDbService {
  final Dio _dio = Dio();
  final String _apiKey = '56a6abda307fd5df7d52e79e36bd46fc';
  final String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> _fetchPaginated(String endpoint, String category, Map<String, dynamic> baseParams) async {
    final List<Movie> allMovies = [];
    try {
      baseParams['api_key'] = _apiKey;
      
      final firstPageResponse = await _dio.get('$_baseUrl$endpoint', queryParameters: {...baseParams, 'page': 1});
      final results = firstPageResponse.data['results'] as List;
      allMovies.addAll(results.map((data) => Movie.fromTMDb(data, category)));

      int totalPages = firstPageResponse.data['total_pages'] ?? 1;
      
      const int pageLimit = 2; // Reduced page limit to 2
      if (totalPages > pageLimit) {
        totalPages = pageLimit;
      }

      if (totalPages > 1) {
        final List<Future<Response>> futures = [];
        for (int page = 2; page <= totalPages; page++) {
          futures.add(_dio.get('$_baseUrl$endpoint', queryParameters: {...baseParams, 'page': page}));
        }

        final responses = await Future.wait(futures);

        for (final response in responses) {
          final pageResults = response.data['results'] as List;
          allMovies.addAll(pageResults.map((data) => Movie.fromTMDb(data, category)));
        }
      }
      developer.log('Загружено ${allMovies.length} записей для категории "$category" из $totalPages страниц.', name: 'TMDbService');
    } catch (e) {
        if (e is DioException && e.response?.statusCode == 429) {
            developer.log('Превышен лимит запросов к API TMDb. Попробуйте позже.', name: 'TMDbService', level: 1000);
        } else {
            developer.log('Ошибка при постраничной загрузке для "$category": $e', name: 'TMDbService', level: 1000);
        }
    }
    return allMovies;
  }

  Future<List<Movie>> fetchAllMovies() async {
    developer.log('Начало масштабной загрузки всех данных из TMDb...', name: 'TMDbService');
    final List<Movie> allContent = [];

    final results = await Future.wait([
      _fetchPaginated('/movie/popular', 'Новинка', {'language': 'ru-RU'}),
      _fetchPaginated('/movie/top_rated', 'Фильм', {'language': 'ru-RU'}),
      _fetchPaginated('/tv/popular', 'Сериал', {'language': 'ru-RU'}),
      _fetchPaginated('/tv/top_rated', 'Сериал', {'language': 'ru-RU'}),
      _fetchPaginated('/discover/movie', 'Мультфильм', {'language': 'ru-RU', 'with_genres': 16, 'sort_by': 'popularity.desc'}),
      _fetchPaginated('/discover/tv', 'Аниме', {'language': 'ru-RU', 'with_original_language': 'ja', 'with_genres': '16,10759', 'sort_by': 'popularity.desc'}),
    ]);

    for (var res in results) {
        allContent.addAll(res);
    }

    final Map<int, Movie> uniqueMovies = {};
    for (var movie in allContent) {
        if (movie.tmdbId != 0) { 
            uniqueMovies[movie.tmdbId] = movie;
        }
    }

    final finalLlist = uniqueMovies.values.toList();
    developer.log('Загрузка завершена. Всего уникальных записей: ${finalLlist.length}', name: 'TMDbService');
    return finalLlist;
  }

  Future<Movie> fetchMovieDetails(int id, String category) async {
    developer.log('Запрос деталей для ID: $id, Категория: $category', name: 'TMDbService');
    String endpoint;
    switch (category) {
      case 'Фильм':
      case 'Новинка':
      case 'Мультфильм':
        endpoint = '/movie/$id';
        break;
      case 'Сериал':
      case 'Аниме':
        endpoint = '/tv/$id';
        break;
      default:
        developer.log('Неизвестная категория: $category', name: 'TMDbService', level: 1000);
        throw Exception('Неизвестная категория: $category');
    }

    try {
      final response = await _dio.get(
        '$_baseUrl$endpoint',
        queryParameters: {'api_key': _apiKey, 'language': 'ru-RU'},
      );
      return Movie.fromTMDb(response.data, category);
    } catch (e) {
      developer.log('Ошибка при загрузке деталей для ID $id: $e', name: 'TMDbService', level: 1000);
      throw Exception('Ошибка при загрузке деталей фильма.');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    developer.log('Поиск фильмов с запросом: $query', name: 'TMDbService');
    try {
      final response = await _dio.get(
        '$_baseUrl/search/multi',
        queryParameters: {
          'api_key': _apiKey,
          'language': 'ru-RU',
          'query': query,
          'page': 1,
          'include_adult': false,
        },
      );
      final results = response.data['results'] as List;
      final movies = results
          .map((data) => Movie.fromTMDb(data, _getCategoryFromMediaType(data['media_type'])))
          .where((movie) => movie.posterUrl.isNotEmpty)
          .toList();

      developer.log('Найдено ${movies.length} результатов по запросу "$query"', name: 'TMDbService');
      return movies;
    } catch (e) {
      developer.log('Ошибка при поиске: $e', name: 'TMDbService', level: 1000);
      return [];
    }
  }

  String _getCategoryFromMediaType(String? mediaType) {
    switch (mediaType) {
      case 'movie':
        return 'Фильм';
      case 'tv':
        return 'Сериал';
      default:
        return 'Новинка'; 
    }
  }
}
