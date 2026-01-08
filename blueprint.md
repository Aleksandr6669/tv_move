# Blueprint: Movie TV App with Firebase

## Overview

This application will display a list of movies fetched from a Firebase Firestore database. It is designed for a TV-like experience, with navigation optimized for remote control interaction. The app will function even when offline, thanks to Firestore's caching capabilities, and will handle cases where no movie data is available.

## Project Structure

*   `lib/main.dart`: The main entry point of the application, responsible for initializing Firebase.
*   `lib/models/movie.dart`: The data model for a movie, including a URL for the video player.
*   `lib/services/firebase_service.dart`: A service to stream movie data from Firestore.
*   `lib/screens/home_screen.dart`: The main screen that displays a grid of movies, adapted for TV navigation.
*   `lib/screens/details_screen.dart`: A screen to display movie details and a button to play the movie.
*   `lib/screens/video_player_screen.dart`: A dedicated screen for playing the movie video.
*   `lib/widgets/movie_card.dart`: A widget to display a single movie in the list, adapted for TV focus.

## Features

*   Displays a list of movies from a Firestore collection.
*   Offline capability: The app will run and show cached data even without a network connection.
*   Handles empty state gracefully if the Firestore collection is empty.
*   TV-friendly UI with focus-based navigation.
*   Integrated video player to stream movies from a URL.
*   Uses the `provider` package for state management.
*   Uses `google_fonts` for custom fonts.

## Firebase Setup

*   **Firestore Database:** The app uses a Firestore collection named `movies`.
*   **Data Model in Firestore:** Each document in the `movies` collection should have the following fields:
    *   `id` (number)
    *   `title` (string)
    *   `overview` (string)
    *   `posterPath` (string, full URL to the image)
    *   `voteAverage` (number)
    *   `videoUrl` (string, full URL to the video file)
