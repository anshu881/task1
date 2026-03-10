# To-Do List App with Firebase

A robust To-Do List application built with Flutter, featuring Firebase Authentication and Firebase Realtime Database integration.

## Features

### ✅ User Authentication
- **Email/Password Authentication**: Secure sign up and login
- **Google Sign In**: Optional Google authentication
- **Session Management**: Automatic session handling

### ✅ Task Management (CRUD)
- **View Tasks**: See all your tasks in a clean list
- **Add Tasks**: Create new tasks with title and description
- **Edit Tasks**: Update existing tasks
- **Mark Complete**: Toggle task completion status
- **Delete Tasks**: Remove tasks you no longer need
- **Search**: Search tasks by title or description
- **Filter**: Filter tasks by status (All, Completed, Pending)
- **Pull-to-Refresh**: Swipe down to refresh your task list

### ✅ State Management
- **Riverpod**: Modern state management solution
- **Authentication State**: Tracks login/logout state
- **Task State**: Manages all task operations

### ✅ Database Integration
- **Firebase Realtime Database**: Stores tasks using REST API calls
- **Real-time Updates**: Tasks sync automatically

### ✅ Responsive Design
- **Mobile First**: Optimized for mobile devices
- **Tablet Support**: Responsive layout for tablets
- **Adaptive UI**: Adjusts to different screen sizes

## Setup Instructions

### 1. Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Enable **Authentication**:
   - Go to Authentication → Sign-in method
   - Enable **Email/Password**
   - Enable **Google** (for Google Sign In)
4. Enable **Realtime Database**:
   - Go to Realtime Database
   - Create database (Start in test mode for development)
   - Copy your database URL (format: `https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com`)

### 2. Firebase Configuration

#### Option A: Using FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This will generate `firebase_options.dart` automatically.

#### Option B: Manual Configuration

1. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from Firebase Console
2. Place `google-services.json` in `android/app/`
3. Place `GoogleService-Info.plist` in `ios/Runner/`
4. Update `lib/utils/firebase_constants.dart` with your database URL

### 3. Update Firebase Constants

Edit `lib/utils/firebase_constants.dart`:

```dart
static const String databaseUrl = 'https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com';
```

### 4. Firebase Database Rules

Update your Realtime Database rules in Firebase Console:

```json
{
  "rules": {
    "users": {
      "$uid": {
        "tasks": {
          ".read": "$uid === auth.uid",
          ".write": "$uid === auth.uid"
        }
      }
    }
  }
}
```

### 5. Android Configuration

#### Update `android/app/build.gradle`:

```gradle
dependencies {
    // ... existing dependencies
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-database'
}
```

#### Update `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### 6. iOS Configuration

1. Add `GoogleService-Info.plist` to `ios/Runner/`
2. Update `ios/Runner/Info.plist` with your reversed client ID

### 7. Install Dependencies

```bash
flutter pub get
```

### 8. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                          # App entry point with Firebase initialization
├── models/
│   ├── task.dart                     # Task model
│   └── user.dart                     # User model
├── services/
│   ├── firebase_auth_service.dart    # Firebase Authentication service
│   └── firebase_database_service.dart # Firebase Realtime Database service (REST API)
├── repositories/
│   ├── auth_repository.dart          # Authentication repository
│   └── task_repository.dart          # Task repository
├── providers/
│   ├── auth_provider.dart            # Auth state management
│   └── task_provider.dart            # Task state management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart         # Login screen with Google Sign In
│   │   └── register_screen.dart      # Registration screen
│   └── tasks/
│       ├── task_dashboard_screen.dart # Main task list screen
│       └── task_form_screen.dart     # Add/Edit task screen
└── utils/
    └── firebase_constants.dart        # Firebase configuration constants
```

## Building APK

### Debug APK
```bash
flutter build apk --debug
```

### Release APK
```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

## Key Features Implementation

### Firebase Authentication
- Email/Password authentication
- Google Sign In (optional)
- Secure session management
- Automatic token refresh

### Firebase Realtime Database
- REST API integration (no SDK dependency for database)
- User-specific task storage (`/users/{userId}/tasks`)
- Real-time data synchronization
- Efficient querying and filtering

### State Management
- Riverpod for reactive state management
- Stream-based authentication state
- AsyncValue for loading/error/success states

### Responsive Design
- Mobile-first approach
- Adaptive layouts for tablets
- Flexible UI components

## Database Structure

```
/users
  /{userId}
    /tasks
      /{taskId}
        - title: string
        - description: string
        - completed: boolean
        - createdAt: timestamp
        - updatedAt: timestamp
```

## Troubleshooting

### Firebase Not Initialized
- Make sure you've run `flutterfire configure` or manually added Firebase config files
- Check that `firebase_options.dart` exists (if using FlutterFire CLI)

### Authentication Errors
- Verify Email/Password is enabled in Firebase Console
- Check Google Sign In configuration
- Ensure SHA-1 fingerprint is added for Android (for Google Sign In)

### Database Permission Errors
- Check Firebase Database rules
- Ensure user is authenticated before accessing tasks
- Verify database URL is correct

## Submission Requirements

1. **APK File**: Build release APK using `flutter build apk --release`
2. **GitHub Repository**: Push code to GitHub
3. **Repository Link**: Share the GitHub link

## Dependencies

- `flutter_riverpod`: State management
- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `google_sign_in`: Google Sign In
- `http`: REST API calls to Firebase Realtime Database
- `intl`: Internationalization

## Notes

- The app uses Firebase Realtime Database REST API (not the SDK) as per requirements
- All database operations use authenticated REST API calls
- Tasks are stored per user for security
- The app is fully responsive and works on all screen sizes

## License

This project is created for assessment purposes.
