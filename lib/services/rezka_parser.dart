import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'dart:developer' as developer;
import 'package:myapp/models/movie.dart';

class RezkaParser {
  final String baseUrl = 'https://rezka.ag/';

  Future<List<Movie>> parseMovies({required String fromUrl, int maxPages = 3}) async {
    final allMovies = <Movie>[];
    var nextUrl = fromUrl;
    int currentPage = 1;

    final headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
      'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
      'Referer': 'https://www.google.com/' 
    };

    while (nextUrl.isNotEmpty && currentPage <= maxPages) {
      developer.log('RezkaParser: Парсинг страницы $currentPage: $nextUrl', name: 'RezkaParser');
      try {
        final response = await http.get(Uri.parse(nextUrl), headers: headers);
        if (response.statusCode != 200) {
          developer.log('RezkaParser: Ошибка загрузки страницы $nextUrl: статус ${response.statusCode}', name: 'RezkaParser', error: response.body);
          break;
        }

        var document = html_parser.parse(response.body);

        var movieElements = document.querySelectorAll('div.b-content__inline_item');
        developer.log('RezkaParser: Найдено ${movieElements.length} фильмов на странице', name: 'RezkaParser');

        if (movieElements.isEmpty && currentPage == 1) {
            developer.log('RezkaParser: Фильмы не найдены, возможно, структура страницы изменилась или запрос заблокирован. HTML-ответ: ${response.body.substring(0, 500)}', name: 'RezkaParser');
            break;
        }

        for (var movieElement in movieElements) {
          final title = movieElement.querySelector('.b-content__inline_item-link a')?.text.trim() ?? 'Нет названия';
          final posterUrl = movieElement.querySelector('.b-content__inline_item-cover img')?.attributes['src'] ?? '';
          final yearAndGenre = movieElement.querySelector('.b-content__inline_item-link div')?.text.trim() ?? '';

          String year = 'N/A';
          List<String> genres = ['Нет жанра'];

          if (yearAndGenre.isNotEmpty) {
            final parts = yearAndGenre.split(',');
            if (parts.isNotEmpty) {
              year = parts[0].trim();
            }
            if (parts.length > 1) {
              genres = parts.sublist(1).map((e) => e.trim()).toList();
            }
          }
          
          final description = movieElement.querySelector('.b-content__inline_item-desc')?.text.trim() ?? 'Нет описания';

          allMovies.add(Movie(
            title: title,
            posterUrl: posterUrl,
            year: year,
            genres: genres,
            description: description,
            category: genres.isNotEmpty ? genres.first : 'Фильм',
          ));
        }

        final nextLinkElement = document.querySelector('a.b-navigation__next');
        if (nextLinkElement != null) {
          nextUrl = nextLinkElement.attributes['href'] ?? '';
        } else {
          nextUrl = ''; 
        }

        currentPage++;

      } catch (e, stacktrace) {
        developer.log('RezkaParser: Ошибка во время парсинга $nextUrl', name: 'RezkaParser', error: e, stackTrace: stacktrace);
        break; 
      }
    }
    developer.log('RezkaParser: Парсинг категории завершен. Всего собрано ${allMovies.length} фильмов.', name: 'RezkaParser');
    return allMovies;
  }
}
