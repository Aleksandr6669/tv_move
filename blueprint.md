
# Movie App Blueprint

## Overview

This document outlines the plan for creating a Flutter application to browse a collection of movies and TV series. The application will feature a modern, visually appealing interface with a focus on user experience and will use a local service to simulate fetching data.

## Style, Design, and Features (Version 3)

*   **UI:** Modern, visually appealing interface with a side navigation menu and a grid-based layout for displaying movies. The UI is designed to be responsive and intuitive for TV navigation.
*   **Navigation:**
    *   Side navigation menu with categories: "Популярное", "Новинки", "Фильмы", "Сериалы", "Мультфильмы", "Аниме", "Фильтр", "Закладки", "История", "Поиск".
    *   Keyboard navigation support for both the menu and the content grid.
    *   Selected items are highlighted, and focus management provides a smooth user experience.
*   **Data Model:** A `Movie` class to represent movies and series, including details like title, poster URL, IMDb rating, year, duration, and category.
*   **Data Service:** A `TMDbService` class (`lib/services/tmdb_service.dart`) that simulates fetching movie data. It currently uses a hardcoded list of movies and will be updated to fetch from a real API later. It includes methods to:
    *   Fetch all movies.
    *   Fetch movie details by ID.
    *   Fetch trailers.
*   **Widgets:**
    *   `MovieCard`: A reusable widget to display individual movie information with a poster and title. It handles hover effects and tap gestures to navigate to the movie details screen.
    *   `MovieDetailsScreen`: A screen to display detailed information about a selected movie, including a trailer player.
    *   Category Screens (`MoviesScreen`, `SeriesScreen`, etc.): Screens that filter and display movies based on their category.
    *   `SearchScreen`: A dedicated screen for searching movies.
*   **State Management:** `StatefulWidget` and `FutureBuilder` are used to manage the state of fetching and displaying movie data asynchronously.
*   **Theming:** A dark theme with a custom color scheme and font styles to create a cinematic feel.

## Current Plan: Refactoring and UI Enhancement

The goal of this refactoring was to move from a single list of movies to a categorized browsing experience, preparing the app for more complex data sources and features.

### Step 1: Create a Centralized Data Service (`TMDbService`)

*   **Action:** Created `lib/services/tmdb_service.dart`.
*   **Details:** This service centralizes all data-fetching logic. Initially, it returns a hardcoded list of `Movie` objects, simulating an API call. It includes methods like `fetchAllMovies`, `getMovieDetails`, and `getMovieTrailers`. This makes the data layer independent of the UI.

### Step 2: Develop Category-Specific Screens

*   **Action:** Created individual screens for each category in the `lib/screens/` directory (`NewReleasesScreen`, `MoviesScreen`, `SeriesScreen`, `CartoonsScreen`, `AnimeScreen`).
*   **Details:** Each screen is a `StatefulWidget` that uses the `TMDbService` to fetch the full list of movies and then filters them based on its specific category (e.g., 'Фильм', 'Сериал'). The filtered list is then displayed in a `GridView`.

### Step 3: Implement the Main Navigation Structure (`MainScreen`)

*   **Action:** Refactored `lib/main.dart` to include a `MainScreen` widget.
*   **Details:** `MainScreen` now contains a side navigation menu and a main content area. It manages the selected category (`_selectedIndex`) and dynamically displays the corresponding screen (e.g., `MoviesScreen`, `SeriesScreen`) using the `_getScreen` method. It also handles keyboard navigation for TV compatibility.

### Step 4: Enhance the `MovieCard` and Create `MovieDetailsScreen`

*   **Action:** Modified `lib/widgets/movie_card.dart` and created `lib/screens/movie_details_screen.dart`.
*   **Details:** `MovieCard` was updated to handle `onTap` events, which navigate to the `MovieDetailsScreen`, passing the `movieId` and the `TMDbService` instance. The `MovieDetailsScreen` fetches detailed movie data and associated trailers using the service and displays them.

### Step 5: Implement Search Functionality

*   **Action:** Created `lib/screens/search_screen.dart`.
*   **Details:** A dedicated search screen was implemented with a `TextField` to input queries. It filters movies based on the search term and displays the results in a grid, reusing the `MovieCard` widget.

### Step 6: Code Cleanup and Finalization

*   **Action:** Removed obsolete files and ensured consistency across the codebase.
*   **Details:** Deleted unused screen files (`history_screen.dart`, `movie_list_screen.dart`, `settings_screen.dart`). Verified that all category screens correctly instantiate and use the `TMDbService` passed down from `MainScreen`. Ensured all `MovieCard` instances receive the `tmdbService` to allow navigation to the details screen.

This refactoring establishes a scalable architecture, improves code organization by separating concerns, and provides a much richer user experience with categorized browsing and search functionality.
