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
  static const int _crossAxisCount = 5;

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final results = await widget.firestoreService.searchMovies(query);
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            autofocus: true, 
            decoration: const InputDecoration(
              labelText: 'Поиск по названию',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
            const Expanded(
              child: Center(child: Text('Ничего не найдено')),
            )
          else
            Expanded(
              child: Focus(
                focusNode: widget.contentFocusNode,
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 10),
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
                ),
              ),
            ),
        ],
      ),
    );
  }
}
