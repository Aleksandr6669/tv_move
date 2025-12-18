import 'package:flutter/material.dart';
import 'package:myapp/models/movie.dart';

// УПРОЩЕНО: Теперь это StatelessWidget
class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isFocused; // Флаг, который передает родитель

  const MovieCard({
    super.key,
    required this.movie,
    this.isFocused = false, // По умолчанию не в фокусе
  });

  @override
  Widget build(BuildContext context) {
    // Радиус скругления и толщина рамки
    const double borderRadius = 8.0;
    const double borderWidth = 4.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: isFocused
            ? Border.all(color: Colors.white, width: borderWidth)
            : Border.all(color: Colors.transparent, width: borderWidth),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      // ClipRRect обеспечивает скругление углов у изображения
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - (borderWidth / 2)),
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            title: Text(
              movie.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // ИСПОЛЬЗУЕМ ПРАВИЛЬНЫЕ ГЕТТЕРЫ
            subtitle: Text(
              '${movie.year} • ${movie.category}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          child: Image.network(
            // ИСПОЛЬЗУЕМ ПРАВИЛЬНЫЕ ГЕТТЕРЫ
            movie.posterUrl, 
            fit: BoxFit.cover,
            // Пока изображение загружается, показываем фон
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[850],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              );
            },
            // В случае ошибки загрузки, показываем иконку
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[850],
                child: const Center(
                  child: Icon(Icons.movie, color: Colors.white54, size: 40),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
