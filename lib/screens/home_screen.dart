import 'package:flutter/material.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/services/tmdb_service.dart';
import 'package:myapp/widgets/movie_carousel.dart';

class HomeScreen extends StatefulWidget {
  final TMDbService tmdbService;
  final FocusNode menuFocusNode;

  const HomeScreen({
    super.key,
    required this.tmdbService,
    required this.menuFocusNode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Center(
          child: TabPageSelector(
            controller: _tabController,
            selectedColor: Colors.green,
            color: Colors.grey,
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _tabController.index = index;
        },
        children: [
          _buildCarouselPage(),
          _buildRecommendationsPage(),
        ],
      ),
    );
  }

  Widget _buildCarouselPage() {
    final Future<List<Movie>> moviesFuture = widget.tmdbService.fetchAllMovies();

    return FutureBuilder<List<Movie>>(
      future: moviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Нет популярных фильмов', style: const TextStyle(color: Colors.white)));
        }

        final allMovies = snapshot.data!;
        final categories = {
          'Новинка': <Movie>[],
          'Фильм': <Movie>[],
          'Сериал': <Movie>[],
          'Мультфильм': <Movie>[],
          'Аниме': <Movie>[],
        };

        for (var movie in allMovies) {
          if (categories.containsKey(movie.category)) {
            categories[movie.category]!.add(movie);
          }
        }
        
        categories.removeWhere((key, value) => value.isEmpty);

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: categories.entries.map((entry) {
            return MovieCarousel(
              title: entry.key,
              movies: entry.value,
              tmdbService: widget.tmdbService,
              menuFocusNode: widget.menuFocusNode,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRecommendationsPage() {
    return const Center(
      child: Text(
        'Рекомендации (скоро)',
        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
