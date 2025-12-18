import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id; // ID документа в Firestore
  final int tmdbId; // Уникальный ID из TMDb
  final String title;
  final String description;
  final String posterUrl;
  final int year;
  final String category;
  final double rating;
  final List<String> genres;
  final Timestamp? createdAt;

  Movie({
    required this.id,
    required this.tmdbId,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.year,
    required this.category,
    required this.rating,
    this.genres = const [],
    this.createdAt,
  });

  // Factory для создания из документа Firestore
  factory Movie.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Movie(
      id: doc.id,
      tmdbId: data['tmdbId'] ?? 0, // Загружаем tmdbId
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      posterUrl: data['posterUrl'] ?? '',
      year: _parseDynamicYear(data['year']), 
      category: data['category'] ?? '',
      rating: _parseDynamicRating(data['rating']), 
      genres: List<String>.from(data['genres'] ?? []),
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  // Factory для создания из данных TMDb
  factory Movie.fromTMDb(Map<String, dynamic> data, String category) {
    return Movie(
      id: '', // ID будет присвоен Firestore
      tmdbId: data['id'] ?? 0, // Сохраняем ID из TMDb
      title: data['title'] ?? data['name'] ?? '',
      description: data['overview'] ?? '',
      posterUrl: data['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${data['poster_path']}'
          : '',
      year: _parseDate(data['release_date'] ?? data['first_air_date'] ?? ''),
      category: category,
      rating: (data['vote_average'] ?? 0.0).toDouble(),
      genres: data['genres'] != null 
          ? List<String>.from(data['genres'].map((g) => g['name'] as String)) 
          : [],
    );
  }

  // Метод для конвертации в JSON для Firestore
  Map<String, dynamic> toJson() {
    return {
      'tmdbId': tmdbId, // Сохраняем tmdbId
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'year': year,
      'category': category,
      'rating': rating,
      'genres': genres,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(), 
    };
  }

  // Вспомогательные функции
  static int _parseDynamicYear(dynamic year) {
    if (year is int) return year;
    if (year is String) return int.tryParse(year) ?? 0;
    return 0;
  }

  static double _parseDynamicRating(dynamic rating) {
    if (rating is double) return rating;
    if (rating is int) return rating.toDouble();
    if (rating is String) return double.tryParse(rating) ?? 0.0;
    return 0.0;
  }

  static int _parseDate(String date) {
    if (date.isEmpty) return 0;
    try {
      return DateTime.parse(date).year;
    } catch (e) {
      return 0;
    }
  }
}
