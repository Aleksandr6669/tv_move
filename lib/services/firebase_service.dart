import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/movie.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Movie>> getMovies({String? category}) {
    Query query = _firestore.collection('movies');

    if (category != null && category != 'All') {
      query = query.where('genres', arrayContains: category);
    }

    return query.snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
      } catch (e) {
        print('Error parsing movies: $e');
        return [];
      }
    });
  }

  Future<void> addSampleMovies() async {
    final CollectionReference movies = _firestore.collection('movies');

    final sampleMovies = [
      {
        'id': 1,
        'title': 'The Shawshank Redemption',
        'overview': 'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.',
        'posterPath': 'https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg',
        'voteAverage': 9.3,
        'videoUrl': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'genres': ['Drama'],
      },
      {
        'id': 2,
        'title': 'The Godfather',
        'overview': 'The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.',
        'posterPath': 'https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsRolD1fZdja1.jpg',
        'voteAverage': 9.2,
        'videoUrl': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        'genres': ['Drama', 'Crime'],
      },
      {
        'id': 3,
        'title': 'The Dark Knight',
        'overview': 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
        'posterPath': 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
        'voteAverage': 9.0,
        'videoUrl': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'genres': ['Action', 'Crime', 'Drama'],
      },
            {
        'id': 4,
        'title': 'Pulp Fiction',
        'overview': 'The lives of two mob hitmen, a boxer, a gangster and his wife, and a pair of diner bandits intertwine in four tales of violence and redemption.',
        'posterPath': 'https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg',
        'voteAverage': 8.9,
        'videoUrl': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        'genres': ['Crime', 'Thriller'],
      },
      {
        'id': 5,
        'title': 'Forrest Gump',
        'overview': 'The presidencies of Kennedy and Johnson, the Vietnam War, the Watergate scandal and other historical events unfold from the perspective of an Alabama man with an IQ of 75, whose only desire is to be reunited with his childhood sweetheart.',
        'posterPath': 'https://image.tmdb.org/t/p/w500/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg',
        'voteAverage': 8.8,
        'videoUrl': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        'genres': ['Comedy', 'Drama', 'Romance'],
      },
      {
        'id': 6,
        'title': 'Inception',
        'overview': 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.',
        'posterPath': 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
        'voteAverage': 8.8,
        'videoUrl': 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        'genres': ['Action', 'Science Fiction', 'Adventure'],
      },
    ];

    for (var movieData in sampleMovies) {
      await movies.doc(movieData['id'].toString()).set(movieData);
    }
  }
}
