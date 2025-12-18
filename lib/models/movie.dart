import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String year;
  final List<String> genres;
  final String rating;
  final String category;
  final String titleLowercase;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.year,
    required this.genres,
    required this.rating,
    required this.category,
  }) : titleLowercase = title.toLowerCase();

  factory Movie.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Movie(
      id: doc.id,
      title: data['title'] ?? 'Без названия',
      description: data['description'] ?? '',
      posterUrl: data['posterUrl'] ?? '',
      year: data['year'] ?? 'N/A',
      genres: List<String>.from(data['genres'] ?? []),
      rating: data['rating']?.toString() ?? '0.0',
      category: data['category'] ?? 'Неизвестно',
    );
  }

  factory Movie.fromTMDb(Map<String, dynamic> data, String category) {
    final genreList = (data['genres'] as List?)
        ?.map((genre) => genre['name'] as String)
        .toList() ?? [];
    
    String getPosterUrl(String? path) {
      if (path != null) {
        return 'https://image.tmdb.org/t/p/w500$path';
      }
      return 'https://via.placeholder.com/500x750.png?text=No+Image';
    }

    String getYear(String? releaseDate) {
        if (releaseDate != null && releaseDate.length >= 4) {
          return releaseDate.substring(0, 4);
        }
        return 'N/A';
    }

    String releaseDate = data['release_date'] ?? data['first_air_date'] ?? '';

    return Movie(
      id: (data['id'] ?? 0).toString(),
      title: data['title'] ?? data['name'] ?? 'Без названия',
      description: data['overview'] ?? '',
      posterUrl: getPosterUrl(data['poster_path']),
      year: getYear(releaseDate),
      genres: genreList,
      rating: (data['vote_average'] ?? 0).toStringAsFixed(1),
      category: category,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'year': year,
      'genres': genres,
      'rating': rating,
      'category': category,
      'titleLowercase': titleLowercase,
    };
  }
}
