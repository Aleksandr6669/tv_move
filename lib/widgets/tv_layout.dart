import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Нам нужен доступ к MovieCard
import 'package:myapp/models/movie.dart'; // и Movie

class TvLayout extends StatefulWidget {
  final FocusNode parentFocusNode;
  final FocusNode menuFocusNode;
  final int itemCount;
  // ИЗМЕНЕНО: itemBuilder теперь передает Movie и флаг isFocused
  final Widget Function(BuildContext, int, bool) itemBuilder;
  final List<Movie> movies; // Требуем список фильмов
  final int crossAxisCount;

  const TvLayout({
    super.key,
    required this.parentFocusNode,
    required this.menuFocusNode,
    required this.itemCount,
    required this.itemBuilder,
    required this.movies,
    this.crossAxisCount = 5,
  });

  @override
  State<TvLayout> createState() => _TvLayoutState();
}

class _TvLayoutState extends State<TvLayout> {
  int _focusedIndex = -1; // Индекс элемента в фокусе, -1 означает отсутствие фокуса

  @override
  void initState() {
    super.initState();
    // Слушатель для родительского узла фокуса
    widget.parentFocusNode.addListener(_onParentFocusChange);
    // Если узел уже в фокусе при инициализации
    if (widget.parentFocusNode.hasFocus) {
       _onParentFocusChange();
    }
  }

  @override
  void dispose() {
    widget.parentFocusNode.removeListener(_onParentFocusChange);
    super.dispose();
  }

  // Когда фокус приходит на контентную часть или уходит с нее
  void _onParentFocusChange() {
    if (widget.parentFocusNode.hasFocus && _focusedIndex == -1) {
      // Если контент получил фокус, а ни одна карточка не выбрана, выбираем первую
      setState(() {
        _focusedIndex = 0;
      });
    } else if (!widget.parentFocusNode.hasFocus) {
      // Если контент потерял фокус, сбрасываем выбор
      setState(() {
        _focusedIndex = -1;
      });
    }
  }

  // Обработчик нажатий клавиш для навигации
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent || !widget.parentFocusNode.hasFocus || _focusedIndex == -1) return;

    int newIndex = _focusedIndex;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_focusedIndex % widget.crossAxisCount == 0) {
        // Если мы в первом столбце, переходим в боковое меню
        setState(() => _focusedIndex = -1);
        widget.menuFocusNode.requestFocus();
      } else {
        newIndex--;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if ((_focusedIndex + 1) % widget.crossAxisCount != 0 && _focusedIndex + 1 < widget.itemCount) {
        newIndex++;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_focusedIndex >= widget.crossAxisCount) {
        newIndex -= widget.crossAxisCount;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_focusedIndex + widget.crossAxisCount < widget.itemCount) {
        newIndex += widget.crossAxisCount;
      }
    }

    if (newIndex != _focusedIndex) {
      setState(() {
        _focusedIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) {
      return const Center(child: Text('Нет данных для отображения'));
    }

    // Используем RawKeyboardListener для перехвата событий навигации
    return RawKeyboardListener(
      focusNode: widget.parentFocusNode,
      onKey: _handleKeyEvent,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 2 / 3,
          ),
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            // Передаем в itemBuilder флаг, является ли текущий элемент сфокусированным
            return widget.itemBuilder(context, index, index == _focusedIndex);
          },
        ),
      ),
    );
  }
}
