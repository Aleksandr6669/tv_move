import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/movie.dart';
import 'dart:developer' as developer;

class FirestoreService {
  final FirebaseFirestore _db;

  // Приватный конструктор, чтобы предотвратить прямое создание
  FirestoreService._(this._db);

  // Статический асинхронный метод для безопасной инициализации
  static Future<FirestoreService?> initialize() async {
    try {
      final firestore = FirebaseFirestore.instance;
      // УДАЛЕНО: Проверка health_check. Она больше не нужна.
      // await firestore.collection('health_check').limit(1).get();
      developer.log('Firestore instance created successfully.', name: 'FirestoreService');
      return FirestoreService._(firestore);
    } catch (e, stacktrace) {
      developer.log(
        'FATAL: Failed to initialize FirestoreService: $e',
        stackTrace: stacktrace,
        name: 'FirestoreService',
        level: 1000, // SEVERE
      );
      // Возвращаем null, чтобы сигнализировать об ошибке инициализации
      return null;
    }
  }

  // ДОБАВЛЕН НОВЫЙ МЕТОД
  Future<void> addMovie({
    required String title,
    required String description,
    required String posterUrl,
    required String category,
  }) async {
    developer.log('Добавление нового фильма: "$title"', name: 'FirestoreService');
    try {
      final movieCollection = _db.collection('movies');
      await movieCollection.add({
        'title': title,
        'description': description,
        'posterUrl': posterUrl,
        'category': category,
        'titleLowercase': title.toLowerCase(),
      });
      developer.log('Фильм "$title" успешно добавлен.', name: 'FirestoreService');
    } catch (e, stacktrace) {
      developer.log(
        'Ошибка при добавлении фильма "$title": $e',
        stackTrace: stacktrace,
        name: 'FirestoreService',
        level: 1000,
      );
      throw Exception('Не удалось добавить фильм: $e');
    }
  }

  Future<void> addMovies(List<Movie> movies) async {
    developer.log('Начало добавления ${movies.length} фильмов в Firestore...', name: 'FirestoreService');
    WriteBatch batch = _db.batch();
    int count = 0;

    for (final movie in movies) {
      final docRef = _db.collection('movies').doc(movie.id);
      batch.set(docRef, movie.toFirestore());
      count++;

      if (count == 499) {
        try {
          await batch.commit();
          batch = _db.batch();
          count = 0;
          developer.log('Коммит пакета из 499 записей...', name: 'FirestoreService');
        } catch (e, stacktrace) {
          developer.log('Ошибка Firebase при коммите пакета: $e', stackTrace: stacktrace, name: 'FirestoreService');
          throw Exception('Не удалось выполнить коммит пакета: $e');
        }
      }
    }

    if (count > 0) {
       try {
        await batch.commit();
        developer.log('Коммит последнего пакета из $count записей.', name: 'FirestoreService');
       } catch (e, stacktrace) {
          developer.log('Ошибка Firebase при коммите последнего пакета: $e', stackTrace: stacktrace, name: 'FirestoreService');
          throw Exception('Не удалось выполнить коммит последнего пакета: $e');
       }
    }
    developer.log('Успешно добавлено ${movies.length} фильмов.', name: 'FirestoreService');
  }

  Future<List<Movie>> getMoviesByCategory(String category) async {
    try {
      final snapshot = await _db
          .collection('movies')
          .where('category', isEqualTo: category)
          .get();
      
      final movies = snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
      developer.log('Загружено ${movies.length} фильмов для категории "$category"', name: 'FirestoreService');
      return movies;

    } catch (e, stacktrace) {
      developer.log('Ошибка при загрузке фильмов по категории "$category": $e', stackTrace: stacktrace, name: 'FirestoreService');
      throw Exception('Не удалось загрузить фильмы для категории "$category"');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final searchQuery = query.toLowerCase();
      final snapshot = await _db
          .collection('movies')
          .where('titleLowercase', isGreaterThanOrEqualTo: searchQuery)
          .where('titleLowercase', isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .get();

      final movies = snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
      developer.log('Найдено ${movies.length} фильмов по запросу "$query"', name: 'FirestoreService');
      return movies;

    } catch (e, stacktrace) {
      developer.log('Ошибка при поиске фильмов по запросу "$query": $e', stackTrace: stacktrace, name: 'FirestoreService');
      throw Exception('Не удалось выполнить поиск по запросу "$query"');
    }
  }

  Future<void> clearAllMovies() async {
    developer.log('Начало полной очистки коллекции movies...', name: 'FirestoreService');
    try {
      int deletedCount;
      do {
        final snapshot = await _db.collection('movies').limit(500).get();
        deletedCount = snapshot.docs.length;

        if (deletedCount == 0) break;

        final batch = _db.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        developer.log('Удалено $deletedCount документов.', name: 'FirestoreService');

      } while (deletedCount > 0);
      
      developer.log('Очистка коллекции завершена.', name: 'FirestoreService');

    } catch(e, stacktrace) {
       developer.log('Ошибка при очистке коллекции: $e', stackTrace: stacktrace, name: 'FirestoreService');
       throw Exception('Не удалось очистить коллекцию: $e');
    }
  }
}
