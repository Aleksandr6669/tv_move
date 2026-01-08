import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/screens/video_player_screen.dart';

class DetailsScreen extends StatelessWidget {
  final Movie movie;

  const DetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 500.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                movie.title,
                style: GoogleFonts.lato(fontWeight: FontWeight.bold),
              ),
              background: Image.network(
                movie.fullPosterPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey,
                    child: const Icon(Icons.movie, size: 100, color: Colors.white),
                  );
                },
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Overview',
                        style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        movie.overview,
                        style: GoogleFonts.lato(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.star, color: Colors.yellow),
                          const SizedBox(width: 5),
                          Text(
                            '${movie.voteAverage}/10',
                            style: GoogleFonts.lato(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (movie.videoUrl != null && movie.videoUrl!.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoPlayerScreen(videoUrl: movie.videoUrl!),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play Movie'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            textStyle: GoogleFonts.lato(fontSize: 18),
                          ),
                        )
                      else
                        Text(
                          'No video available for this movie.',
                          style: GoogleFonts.lato(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white70),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
