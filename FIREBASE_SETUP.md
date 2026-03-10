# Firebase Setup Instructions

## Quick Setup (Recommended)

### Step 1: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### Step 2: Login to Firebase

```bash
firebase login
```

### Step 3: Configure Firebase for Your Project

```bash
flutterfire configure
```

This will:
- Detect your Firebase projects
- Generate `firebase_options.dart` automatically
- Configure Android and iOS automatically

### Step 4: Update main.dart

After running `flutterfire configure`, update `lib/main.dart`:

```dart
import 'firebase_options.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use this
  );
  
  runApp(
    const ProviderScope(
      child: TodoApp(),
    ),
  );
}
```

## Manual Setup (Alternative)

If you prefer manual setup:

### Step 1: Get Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Click the gear icon ⚙️ → Project Settings
4. Scroll down to "Your apps" section
5. Click on the Web app (</>) icon
6. Copy the Firebase configuration

### Step 2: Update main.dart

Replace the FirebaseOptions in `lib/main.dart` with your actual values:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "AIza...", // Your actual API key
    appId: "1:123456789:web:abc123", // Your actual App ID
    messagingSenderId: "123456789", // Your actual Sender ID
    projectId: "your-project-id", // Your actual Project ID
    authDomain: "your-project-id.firebaseapp.com",
    storageBucket: "your-project-id.appspot.com",
  ),
);
```

### Step 3: Enable Authentication

1. Go to Firebase Console → Authentication
2. Click "Get Started"
3. Enable "Email/Password" sign-in method
4. (Optional) Enable "Google" sign-in method

### Step 4: Create Realtime Database

1. Go to Firebase Console → Realtime Database
2. Click "Create Database"
3. Choose your region
4. Start in "Test mode" (for development)
5. Copy the database URL

### Step 5: Update Database URL

Edit `lib/utils/firebase_constants.dart`:

```dart
static const String databaseUrl = 'https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com';
```

### Step 6: Set Database Rules

In Firebase Console → Realtime Database → Rules:

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

## Verify Setup

After configuration, run:

```bash
flutter run -d chrome
```

The app should start without Firebase initialization errors.

## Troubleshooting

### Error: "FirebaseOptions cannot be null"
- Make sure you've run `flutterfire configure` OR
- Manually added FirebaseOptions in `main.dart`

### Error: "Firebase App named '[DEFAULT]' already exists"
- This means Firebase was initialized twice
- Check that `Firebase.initializeApp()` is only called once

### Error: "Permission denied" when accessing database
- Check your Realtime Database rules
- Ensure user is authenticated before accessing tasks

### Web-specific Issues
- Make sure you've added Firebase config for Web app
- Check browser console for additional errors
- Verify CORS settings if needed
