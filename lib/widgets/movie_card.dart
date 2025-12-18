import 'package:flutter/material.dart';
import 'package:myapp/models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    // Родительский виджет Focus управляет состоянием фокуса.
    // Мы используем Focus.of(context), чтобы получить состояние фокуса и изменить внешний вид.
    final bool hasFocus = Focus.of(context).hasFocus;

    // AnimatedContainer для плавной анимации масштабирования при фокусе
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      transform: hasFocus ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
      transformAlignment: Alignment.center,
      child: Card(
        clipBehavior: Clip.antiAlias, // Обрезаем все, что выходит за границы карточки
        elevation: hasFocus ? 12 : 4,
        shadowColor: hasFocus ? Theme.of(context).focusColor.withOpacity(0.8) : Colors.black.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: hasFocus ? Theme.of(context).focusColor : Colors.transparent,
            width: 3,
          ),
        ),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            // Фоновое изображение (постер)
            Positioned.fill(
              child: Image.network(
                movie.posterUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.movie, color: Colors.white60, size: 40));
                },
              ),
            ),
            
            // Градиентный оверлей для читаемости текста
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.4, 0.6, 1.0],
                ),
              ),
            ),

            // Текстовый контент
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [Shadow(blurRadius: 3.0, color: Colors.black, offset: Offset(2, 2))],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Показываем год и рейтинг, только если они есть
                  if (movie.year.isNotEmpty && movie.rating.isNotEmpty)
                    Text(
                      '${movie.year} \u2022 ${movie.rating} \u2605', // Добавил звезду для рейтинга
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
