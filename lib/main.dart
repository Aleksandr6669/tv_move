import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/screens/admin_screen.dart';
import 'package:myapp/screens/anime_screen.dart';
import 'package:myapp/screens/cartoons_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/movie_list_screen.dart';
import 'package:myapp/screens/movies_screen.dart';
import 'package:myapp/screens/search_screen.dart';
import 'package:myapp/screens/series_screen.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/services/movie_data_service.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final firestoreService = await FirestoreService.initialize();

  if (firestoreService == null) {
    runApp(const ErrorApp("Не удалось подключиться к базе данных."));
    return;
  }

  final movieDataService = MovieDataService(firestoreService: firestoreService);
  final List<Movie> movies = await movieDataService.loadMovies();

  runApp(MyApp(firestoreService: firestoreService, movies: movies));
}

class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 24))),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  final FirestoreService firestoreService;
  final List<Movie> movies;

  const MyApp({super.key, required this.firestoreService, required this.movies});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  final FocusNode _menuFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode(); 

  final List<String> _menuItems = [
    'Главная', 'Фильмы', 'Сериалы', 'Мультфильмы', 'Аниме', 'Поиск', 'Админ'
  ];

  @override
  void dispose() {
    _menuFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _navigateToScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      _contentFocusNode.requestFocus();
    });
  }
  
  Widget _getScreen(int index) {
    switch (index) {
      case 0: return HomeScreen(firestoreService: widget.firestoreService, menuFocusNode: _menuFocusNode, contentFocusNode: _contentFocusNode);
      case 1: return MoviesScreen(firestoreService: widget.firestoreService, menuFocusNode: _menuFocusNode, contentFocusNode: _contentFocusNode);
      case 2: return SeriesScreen(firestoreService: widget.firestoreService, menuFocusNode: _menuFocusNode, contentFocusNode: _contentFocusNode);
      case 3: return CartoonsScreen(firestoreService: widget.firestoreService, menuFocusNode: _menuFocusNode, contentFocusNode: _contentFocusNode);
      case 4: return AnimeScreen(firestoreService: widget.firestoreService, menuFocusNode: _menuFocusNode, contentFocusNode: _contentFocusNode);
      case 5: return SearchScreen(firestoreService: widget.firestoreService, menuFocusNode: _menuFocusNode, contentFocusNode: _contentFocusNode);
      case 6: return AdminScreen(firestoreService: widget.firestoreService, menuFocusNode: _menuFocusNode, navigateToScreen: _navigateToScreen);
      case 7: return MovieListScreen(firestoreService: widget.firestoreService, menuFocusNode: _menuFocusNode, contentFocusNode: _contentFocusNode);
      default: return HomeScreen(firestoreService: widget.firestoreService, menuFocusNode: _menuFocusNode, contentFocusNode: _contentFocusNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTT App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1F1F1F),
        scaffoldBackgroundColor: const Color(0xFF1F1F1F),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        focusColor: const Color(0xFFE50914),
      ),
      home: Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _navigateToScreen,
              labelType: NavigationRailLabelType.all,
              backgroundColor: const Color(0xFF121212),
              indicatorColor: Colors.transparent,
              minWidth: 100,
              destinations: _menuItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return NavigationRailDestination(
                      icon: const SizedBox.shrink(), 
                      label: _NavigationLabel(text: item, isSelected: _selectedIndex == index),
                  );
              }).toList(),
            ),
            Expanded(
              child: Focus(
                focusNode: _contentFocusNode,
                child: _getScreen(_selectedIndex)
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationLabel extends StatelessWidget {
  final String text;
  final bool isSelected;

  const _NavigationLabel({required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final bool hasFocus = Focus.of(context).hasFocus;

    return Container(
      width: double.infinity, 
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2C2C2E) : Colors.transparent,
        border: hasFocus
            ? Border(left: BorderSide(color: Theme.of(context).focusColor, width: 4.0))
            : const Border(),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
