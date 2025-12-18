import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/movie.dart';
import 'dart:developer' as developer;

class FirestoreService {
  final FirebaseFirestore _db;

  // Приватный конструктор
  FirestoreService._(this._db);

  // Статический асинхронный метод для инициализации
  static Future<FirestoreService?> initialize() async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('test_connection').limit(1).get();
      developer.log('Успешное подключение к Firestore.', name: 'FirestoreService');
      return FirestoreService._(firestore);
    } catch (e) {
      developer.log(
        'Ошибка подключения к Firestore. Убедитесь, что вы настроили Firebase для своего проекта и что правила безопасности разрешают чтение/запись.',
        name: 'FirestoreService',
        error: e,
        level: 1000, // SEVERE
      );
      return null;
    }
  }

  // Приватный метод для пакетного добавления
  Future<void> _addMoviesBatch(List<Movie> movies) async {
    final batch = _db.batch();
    final moviesCollection = _db.collection('movies');

    for (var movie in movies) {
      var docRef = moviesCollection.doc();
      batch.set(docRef, movie.toJson());
    }
    await batch.commit();
    developer.log('${movies.length} фильмов было добавлено в Firestore.', name: 'FirestoreService');
  }

  // Публичный метод для добавления одного фильма
  Future<void> addMovie(Movie movie) async {
    try {
      await _db.collection('movies').add(movie.toJson());
      developer.log('Фильм "${movie.title}" добавлен.', name: 'FirestoreService');
    } catch (e) {
      developer.log('Ошибка при добавлении фильма: $e', name: 'FirestoreService', level: 1000);
    }
  }

  Future<bool> hasMovies() async {
    try {
      final snapshot = await _db.collection('movies').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      developer.log('Ошибка при проверке наличия фильмов: $e', name: 'FirestoreService', level: 1000);
      return false;
    }
  }

  Future<List<Movie>> getMoviesByCategory(String category) async {
    try {
      final snapshot = await _db
          .collection('movies')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    } catch (e) {
        developer.log('Ошибка при получении фильмов по категории \'$category\': $e', name: 'FirestoreService', level: 1000);
        return [];
    }
  }

  Future<List<Movie>> getAllMovies() async {
    try {
      final snapshot = await _db.collection('movies').get();
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    } catch (e) {
      developer.log('Ошибка при получении всех фильмов: $e', name: 'FirestoreService', level: 1000);
      return [];
    }
  }

  Future<void> deleteMovie(String id) async {
    try {
      await _db.collection('movies').doc(id).delete();
      developer.log('Фильм с ID $id удален.', name: 'FirestoreService');
    } catch (e) {
      developer.log('Ошибка при удалении фильма с ID $id: $e', name: 'FirestoreService', level: 1000);
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    try {
      final snapshot = await _db
          .collection('movies')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    } catch (e) {
      developer.log('Ошибка при поиске фильмов: $e', name: 'FirestoreService', level: 1000);
      return [];
    }
  }

  Future<void> deleteAllMovies() async {
    try {
      final snapshot = await _db.collection('movies').get();
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      developer.log('Все фильмы были удалены из Firestore.', name: 'FirestoreService');
    } catch (e) {
      developer.log('Ошибка при удалении всех фильмов: $e', name: 'FirestoreService', level: 1000);
    }
  }
   // Добавляем метод для вызова пакетного добавления
   Future<void> addMovies(List<Movie> movies) async {
    await _addMoviesBatch(movies);
  }
}
