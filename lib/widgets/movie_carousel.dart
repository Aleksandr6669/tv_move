import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/widgets/movie_card.dart';

class MovieCarousel extends StatefulWidget {
  final String title;
  final List<Movie> movies;
  // ДОБАВЛЕНО: Фокус-нода для возврата в меню
  final FocusNode menuFocusNode; 

  const MovieCarousel({
    super.key,
    required this.title,
    required this.movies,
    // ДОБАВЛЕНО: Требуем параметр в конструкторе
    required this.menuFocusNode,
  });

  @override
  State<MovieCarousel> createState() => _MovieCarouselState();
}

class _MovieCarouselState extends State<MovieCarousel> {
  int _focusedIndex = -1;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
        ),
        SizedBox(
          height: 270, // Высота карусели
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              final isFocused = _focusedIndex == index;

              // Оборачиваем каждую карточку в Focus, чтобы управлять навигацией
              return Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    if (hasFocus) {
                      _focusedIndex = index;
                      // плавная прокрутка к элементу в фокусе
                      _scrollToIndex(index);
                    } else if (_focusedIndex == index) {
                      _focusedIndex = -1;
                    }
                  });
                },
                 onKey: (node, event) {
                  // ИСПРАВЛЕНИЕ: Логика возврата фокуса в меню
                  if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    if (index == 0) { // Если это первый элемент
                      widget.menuFocusNode.requestFocus(); // Передаем фокус в меню
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MovieCard(movie: movie, isFocused: isFocused),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _scrollToIndex(int index) {
    // Простой расчет для прокрутки, можно улучшить
    double target = index * 160.0; // Ширина карточки + отступ
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

   @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
