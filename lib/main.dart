import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/screens/anime_screen.dart';
import 'package:myapp/screens/bookmarks_screen.dart';
import 'package:myapp/screens/cartoons_screen.dart';
import 'package:myapp/screens/filter_screen.dart';
import 'package:myapp/screens/history_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/movies_screen.dart';
import 'package:myapp/screens/new_releases_screen.dart';
import 'package:myapp/screens/search_screen.dart';
import 'package:myapp/screens/series_screen.dart';
import 'package:myapp/services/tmdb_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTT App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1F1F1F),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white70),
          headlineSmall:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        focusColor: Colors.green,
        colorScheme: const ColorScheme.dark(
          primary: Colors.green,
          secondary: Color(0xFF1F1F1F),
          surface: Color(0xFF1F1F1F),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Default to Home
  final FocusNode _menuFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Главная', 'icon': Icons.home_outlined},
    {'title': 'Новинки', 'icon': Icons.new_releases_outlined},
    {'title': 'Фильмы', 'icon': Icons.movie_outlined},
    {'title': 'Сериалы', 'icon': Icons.tv_outlined},
    {'title': 'Мультфильмы', 'icon': Icons.child_friendly_outlined},
    {'title': 'Аниме', 'icon': Icons.animation_outlined},
    {'title': 'Фильтр', 'icon': Icons.filter_alt_outlined},
    {'title': 'Закладки', 'icon': Icons.bookmark_border},
    {'title': 'История', 'icon': Icons.history},
    {'title': 'Поиск', 'icon': Icons.search_outlined},
  ];

  late final TMDbService _tmdbService;

  @override
  void initState() {
    super.initState();
    _tmdbService = TMDbService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusScope.of(context).requestFocus(_menuFocusNode);
    });
  }

  @override
  void dispose() {
    _menuFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _onMenuItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) FocusScope.of(context).requestFocus(_contentFocusNode);
    });
  }

  Widget _getScreen(int index) {
    switch (_menuItems[index]['title']) {
      case 'Главная':
        return HomeScreen(
          tmdbService: _tmdbService,
          menuFocusNode: _menuFocusNode,
        );
      case 'Новинки':
        return NewReleasesScreen(tmdbService: _tmdbService, menuFocusNode: _menuFocusNode);
      case 'Фильмы':
        return MoviesScreen(tmdbService: _tmdbService, menuFocusNode: _menuFocusNode);
      case 'Сериалы':
        return SeriesScreen(tmdbService: _tmdbService, menuFocusNode: _menuFocusNode);
      case 'Мультфильмы':
        return CartoonsScreen(tmdbService: _tmdbService, menuFocusNode: _menuFocusNode);
      case 'Аниме':
        return AnimeScreen(tmdbService: _tmdbService, menuFocusNode: _menuFocusNode);
      case 'Поиск':
        return SearchScreen(tmdbService: _tmdbService, menuFocusNode: _menuFocusNode);
      case 'Фильтр':
        return FilterScreen(); // Assuming no grid navigation needed here
      case 'Закладки':
        return BookmarksScreen(); // Assuming no grid navigation needed here
      case 'История':
        return HistoryScreen(); // Assuming no grid navigation needed here
      default:
        return NewReleasesScreen(tmdbService: _tmdbService, menuFocusNode: _menuFocusNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 240,
            color: const Color(0xFF191919),
            child: Focus(
              focusNode: _menuFocusNode,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    if (_selectedIndex > 0) {
                      setState(() {
                        _selectedIndex--;
                      });
                    }
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    if (_selectedIndex < _menuItems.length - 1) {
                      setState(() {
                        _selectedIndex++;
                      });
                    }
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                      event.logicalKey == LogicalKeyboardKey.select ||
                      event.logicalKey == LogicalKeyboardKey.enter) {
                    _onMenuItemTapped(_selectedIndex);
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 20),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  final isSelected = _selectedIndex == index;

                  return GestureDetector(
                    onTap: () => _onMenuItemTapped(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      color: isSelected ? Colors.green : Colors.transparent,
                      child: Row(
                        children: [
                          Icon(
                            item['icon'],
                            color:
                                isSelected ? Colors.white : Colors.grey[400],
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            item['title'],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[400],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Focus(
              focusNode: _contentFocusNode,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _getScreen(_selectedIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
