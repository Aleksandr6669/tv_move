import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final int year;
  final String category;
  final double rating;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.year,
    required this.category,
    required this.rating,
  });

  // Фабричный конструктор для создания экземпляра из документа Firestore
  factory Movie.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Movie(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      posterUrl: data['posterUrl'] ?? '',
      year: data['year'] ?? 0,
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
    );
  }

  // Фабричный конструктор для создания экземпляра из данных TMDb
  factory Movie.fromTMDb(Map<String, dynamic> data, String category) {
    return Movie(
      id: (data['id'] ?? 0).toString(),
      title: data['title'] ?? data['name'] ?? '',
      description: data['overview'] ?? '',
      posterUrl: data['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${data['poster_path']}'
          : '', // Можно указать URL-адрес заполнителя
      year: _parseYear(data['release_date'] ?? data['first_air_date'] ?? ''),
      category: category,
      rating: (data['vote_average'] ?? 0.0).toDouble(),
    );
  }

  // Метод для преобразования экземпляра в JSON для Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'year': year,
      'category': category,
      'rating': rating,
    };
  }

  static int _parseYear(String date) {
    if (date.isEmpty) return 0;
    return DateTime.parse(date).year;
  }
}
