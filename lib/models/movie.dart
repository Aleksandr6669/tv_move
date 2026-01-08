import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String? videoUrl;
  final List<String> genres;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    required this.voteAverage,
    this.videoUrl,
    this.genres = const [],
  });

  factory Movie.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Movie(
      id: data['id'] ?? 0,
      title: data['title'] ?? '',
      overview: data['overview'] ?? '',
      posterPath: data['posterPath'],
      voteAverage: (data['voteAverage'] ?? 0).toDouble(),
      videoUrl: data['videoUrl'],
      genres: List<String>.from(data['genres'] ?? []),
    );
  }

  String get fullPosterPath {
    if (posterPath != null && posterPath!.isNotEmpty) {
      return posterPath!;
    }
    return 'https://via.placeholder.com/500x750.png?text=No+Image';
  }
}
