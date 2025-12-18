import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/widgets/movie_card.dart';

class SearchScreen extends StatefulWidget {
  final FirestoreService firestoreService;
  final FocusNode menuFocusNode;
  final FocusNode contentFocusNode;

  const SearchScreen({
    super.key,
    required this.firestoreService,
    required this.menuFocusNode,
    required this.contentFocusNode,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _searchResults = [];
  bool _isLoading = false;
  String _message = 'Начните вводить для поиска';
  static const int _crossAxisCount = 5;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _message = 'Начните вводить для поиска';
      });
      return;
    }

    setState(() { _isLoading = true; });
    try {
      final results = await widget.firestoreService.searchMovies(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
        if (results.isEmpty) {
          _message = 'Ничего не найдено';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Ошибка поиска: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            controller: _searchController,
            autofocus: true, // Сразу фокусируемся на поиске
            decoration: const InputDecoration(
              labelText: 'Поиск по названию',
              filled: true,
              fillColor: Color(0xFF2C2C2E),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isNotEmpty
                  ? GridView.builder(
                      focusNode: widget.contentFocusNode,
                      padding: const EdgeInsets.all(24.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _crossAxisCount,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return Focus(
                          onKey: (node, event) {
                            if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                              if (index % _crossAxisCount == 0) {
                                widget.menuFocusNode.requestFocus();
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: MovieCard(movie: _searchResults[index]),
                        );
                      },
                    )
                  : Center(
                      child: Text(_message, style: const TextStyle(color: Colors.white70, fontSize: 18)),
                    ),
        ),
      ],
    );
  }
}
