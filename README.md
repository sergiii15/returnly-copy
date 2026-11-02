# Returnly

Returnly is a lost-and-found web application developed using Flutter, Dart, and Firebase. The platform allows users to report lost or found items, upload photos, browse posts, and communicate through in-app messaging. Its goal is to simplify item recovery by connecting people who have lost belongings with those who have found them.


## Features

- **User Authentication:** Sign up, log in, and log out using Firebase Authentication.
- **Lost and Found Posts:** Create posts with item descriptions and photos.
- **Search Functionality:** Browse and search for lost or found items.
- **Image Uploads:** Store and retrieve item photos using Firebase Cloud Storage.
- **In-App Messaging:** Communicate with other users through the application's chat system.
- **Meetup Coordination:** Arrange item exchanges using Google Maps and suggested meetup locations.
- **User Profiles:** View and manage personal posts.



## Tech Stack

- **Flutter:** Framework for building the web application's user interface.
- **Dart:** Programming language used to develop the application.
- **Firebase Authentication:** User registration, login, and authentication.
- **Cloud Firestore:** Cloud database for storing posts, user information, and chat data.
- **Firebase Cloud Storage:** Storage and retrieval of uploaded item images.
- **Google Maps:** Map integration for meetup coordination and location selection.
- **Git & GitHub:** Version control and source code management.



## Project Structure

The application is organized into separate directories to keep the code structured and maintainable.

```text
lib/
  models/               # Application data models
  screens/              # Application screens and pages
  services/             # Backend and Firebase services
  widgets/              # Reusable UI components
  main.dart              # Application entry point
  firebase_options.dart  # Firebase configuration
```
