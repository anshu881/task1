# Quick Setup Guide

## Step 1: Firebase Setup

1. Create a Firebase project at https://console.firebase.google.com/
2. Enable Authentication:
   - Go to Authentication → Sign-in method
   - Enable Email/Password
   - Enable Google (optional)
3. Create Realtime Database:
   - Go to Realtime Database → Create Database
   - Start in test mode
   - Copy the database URL

## Step 2: Configure Firebase in Flutter

### Using FlutterFire CLI (Easiest):

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure Firebase for your project
flutterfire configure
```

This will:
- Generate `firebase_options.dart`
- Configure Android and iOS automatically

### Manual Configuration:

1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`
3. Download `GoogleService-Info.plist` from Firebase Console
4. Place it in `ios/Runner/GoogleService-Info.plist`
5. Update `lib/utils/firebase_constants.dart` with your database URL

## Step 3: Update Database URL

Edit `lib/utils/firebase_constants.dart`:

```dart
static const String databaseUrl = 'https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com';
```

Replace `YOUR_PROJECT_ID` with your actual Firebase project ID.

## Step 4: Set Database Rules

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

## Step 5: Install Dependencies

```bash
flutter pub get
```

## Step 6: Run the App

```bash
flutter run
```

## Step 7: Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK (for submission)
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

### Firebase not initialized
- Run `flutterfire configure` or manually add config files
- Check that `firebase_options.dart` exists

### Google Sign In not working (Android)
- Add SHA-1 fingerprint to Firebase Console
- Get SHA-1: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`

### Database permission denied
- Check database rules in Firebase Console
- Ensure user is authenticated
