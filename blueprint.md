
# Movie App Blueprint

## Overview

This document outlines the plan for creating a Flutter application to browse a collection of movies and TV series. The application will feature a modern, visually appealing interface with a focus on user experience and will use Firebase Firestore as its backend.

## Style, Design, and Features (Version 2)

*   **UI:** Modern, card-based layout.
*   **Typography:** Custom fonts using `google_fonts` for better readability and style.
*   **Color Scheme:** A simple and clean color scheme.
*   **Data Model:** A `Movie` class to represent movies and series, adapted for Firestore.
*   **Backend:** Cloud Firestore for real-time data synchronization.
*   **Widgets:**
    *   `MovieCard`: A reusable widget to display individual movie information.
    *   `MovieListScreen`: The main screen displaying a list of movies fetched from Firestore.

## Current Plan

### Step 1: Add Firebase Dependencies

*   Add `firebase_core` and `cloud_firestore` to `pubspec.yaml`.

### Step 2: Initialize Firebase

*   Update `lib/main.dart` to initialize Firebase before the app starts.

### Step 3: Create Firestore Service

*   Create a file `lib/services/firestore_service.dart` to manage all interactions with Firestore, including:
    *   A function to fetch the stream of movies.
    *   A utility function to add the initial sample movies to the database if it's empty.

### Step 4: Update the Movie Model

*   Add a `fromFirestore` factory constructor to the `Movie` class in `lib/models/movie.dart` to easily convert Firestore documents into `Movie` objects.

### Step 5: Update the UI to Use Firestore

*   Modify `lib/screens/movie_list_screen.dart` to be a `StatefulWidget`.
*   Use a `StreamBuilder` to listen for real-time updates from the 'movies' collection in Firestore.
*   Display the movies using the `MovieCard` widget.
*   Add logic to call the service to upload initial data.

### Step 6: Refine `main.dart`

*   Ensure the main function is `async`.
*   Update the theme and app structure as needed.
