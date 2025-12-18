import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'dart:developer' as developer;
import 'package:enough_convert/enough_convert.dart';
import 'package:myapp/models/movie.dart';

class FilmixParser {
  final String baseUrl = 'https://filmix.my';

  Future<List<Movie>> parseMovies({required String fromUrl, int maxPages = 3}) async {
    final allMovies = <Movie>[];
    var nextUrl = fromUrl;
    int currentPage = 1;

    final headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36'
    };

    while (nextUrl.isNotEmpty && currentPage <= maxPages) {
      developer.log('Парсинг страницы $currentPage: $nextUrl', name: 'FilmixParser');
      try {
        final response = await http.get(Uri.parse(nextUrl), headers: headers);
        if (response.statusCode != 200) {
          developer.log('Ошибка загрузки страницы $nextUrl: статус ${response.statusCode}', name: 'FilmixParser');
          break;
        }

        final body = Windows1251Codec().decode(response.bodyBytes);
        var document = html_parser.parse(body);

        var movieElements = document.querySelectorAll('article.shortstory');
        developer.log('Найдено ${movieElements.length} фильмов на странице', name: 'FilmixParser');

        for (var movieElement in movieElements) {
          final title = movieElement.querySelector('h2.name a')?.text.trim() ?? 'Нет названия';
          final posterUrl = movieElement.querySelector('.poster img')?.attributes['src'] ?? '';
          final year = movieElement.querySelector('.item.year .item-content a')?.text.trim() ?? 'N/A';
          final description = movieElement.querySelector('p[itemprop="description"]')?.text.trim() ?? 'Нет описания';
          
          final genreContent = movieElement.querySelector('.item.category .item-content');
          final genres = genreContent?.text.split(',').map((e) => e.trim()).toList() ?? ['Нет жанра'];
          final category = genres.isNotEmpty ? genres.first : 'Фильм';

          final fullPosterUrl = posterUrl.startsWith('http') ? posterUrl : baseUrl + posterUrl;

          allMovies.add(Movie(
            title: title,
            posterUrl: fullPosterUrl,
            year: year,
            genres: genres,
            description: description,
            category: category,
          ));
        }

        final nextLinkElement = document.querySelector('div.navigation a.next');
        if (nextLinkElement != null) {
          nextUrl = nextLinkElement.attributes['href'] ?? '';
          if (nextUrl.isNotEmpty && !nextUrl.startsWith('http')) {
            nextUrl = baseUrl + nextUrl;
          }
        } else {
          nextUrl = ''; 
        }

        currentPage++;

      } catch (e, stacktrace) {
        developer.log('Ошибка во время парсинга $nextUrl', name: 'FilmixParser', error: e, stackTrace: stacktrace);
        break; 
      }
    }
    developer.log('Парсинг категории завершен. Всего собрано ${allMovies.length} фильмов с $maxPages страниц.', name: 'FilmixParser');
    return allMovies;
  }
}
