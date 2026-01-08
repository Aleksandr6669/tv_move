import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/movie.dart';
import 'package:myapp/services/firebase_service.dart';
import 'package:myapp/widgets/category_menu.dart';
import 'package:myapp/widgets/movie_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _selectedCategory = 'All';

  // Define the categories for the menu
  final List<String> _categories = [
    'All',
    'Action',
    'Comedy',
    'Drama',
    'Crime',
    'Romance',
    'Science Fiction',
    'Thriller',
  ];

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie TV', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 28)),
      ),
      body: Row(
        children: [
          // Category Menu on the left
          CategoryMenu(
            categories: _categories,
            onCategorySelected: _onCategorySelected,
          ),

          // Movie Grid on the right
          Expanded(
            child: StreamBuilder<List<Movie>>(
              stream: _firebaseService.getMovies(category: _selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // If there are no movies, show a button to add sample data
                  return Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _firebaseService.addSampleMovies();
                        // Show a snackbar on success
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sample movies added successfully!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: const Text('Add Sample Movies', style: TextStyle(fontSize: 16)),
                    ),
                  );
                } else {
                  final movies = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // More columns for TV
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.7, // Adjust aspect ratio for TV
                    ),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return MovieCard(movie: movie);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
