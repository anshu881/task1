# Task Management System - Mobile App (Flutter)

A complete Task Management System built with Flutter for Android and iOS, following Track B (Mobile Engineer) requirements.

## Features

### Authentication
- ✅ User Registration
- ✅ User Login
- ✅ Secure token storage using `flutter_secure_storage`
- ✅ Automatic token refresh when access token expires
- ✅ Logout functionality

### Task Management (CRUD)
- ✅ Create new tasks
- ✅ View task list with pagination
- ✅ Edit existing tasks
- ✅ Delete tasks
- ✅ Toggle task completion status
- ✅ Filter tasks by status (All, Completed, Pending)
- ✅ Search tasks by title
- ✅ Pull-to-refresh functionality

### Architecture
- ✅ Clean Architecture with separation of concerns:
  - **Models**: Data models (Task, User)
  - **Services**: API service and secure storage service
  - **Repositories**: Business logic layer (AuthRepository, TaskRepository)
  - **Providers**: State management using Riverpod
  - **Screens**: UI layer (Login, Register, Dashboard, Task Form)

### State Management
- ✅ Riverpod for state management
- ✅ AsyncValue for handling loading/error/success states
- ✅ Automatic state updates on CRUD operations

### Error Handling
- ✅ Friendly error messages via Snackbars
- ✅ Proper error handling for API failures
- ✅ Network error handling
- ✅ Validation errors for forms

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Backend API URL

Update the `baseUrl` in `lib/utils/constants.dart`:

```dart
static const String baseUrl = 'http://your-backend-url:3000/api';
```

For Android emulator, use `http://10.0.2.2:3000/api`  
For iOS simulator, use `http://localhost:3000/api`  
For physical device, use your computer's IP address: `http://192.168.x.x:3000/api`

### 3. Backend API Requirements

The app expects a Node.js backend API with the following endpoints:

#### Authentication Endpoints
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - Logout user

#### Task Endpoints
- `GET /api/tasks` - Get tasks (with pagination, filtering, search)
- `POST /api/tasks` - Create new task
- `GET /api/tasks/:id` - Get task by ID
- `PATCH /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task
- `PATCH /api/tasks/:id/toggle` - Toggle task completion

### 4. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── task.dart            # Task model
│   └── user.dart            # User model
├── services/
│   ├── api_service.dart     # API communication service
│   └── storage_service.dart # Secure storage service
├── repositories/
│   ├── auth_repository.dart # Authentication repository
│   └── task_repository.dart # Task repository
├── providers/
│   ├── auth_provider.dart   # Auth state management
│   └── task_provider.dart   # Task state management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── tasks/
│       ├── task_dashboard_screen.dart
│       └── task_form_screen.dart
└── utils/
    └── constants.dart       # API constants and storage keys
```

## Dependencies

- `flutter_riverpod`: State management
- `http`: HTTP client for API calls
- `flutter_secure_storage`: Secure storage for tokens
- `shared_preferences`: Additional storage (if needed)
- `intl`: Internationalization support

## Key Features Implementation

### Token Refresh
The app automatically refreshes the access token when it expires (401 response). The refresh logic is implemented in `api_service.dart`.

### Pagination
Tasks are loaded in batches (10 per page by default). Scroll to the bottom to load more tasks automatically.

### Pull-to-Refresh
Pull down on the task list to refresh all tasks.

### Search & Filter
- Search tasks by title using the search bar
- Filter tasks by status (All, Completed, Pending) using segmented buttons

## Testing

Make sure your backend API is running and accessible before testing the app. The app will show appropriate error messages if the backend is not available.

## Notes

- The app uses secure storage for tokens, ensuring they are encrypted and stored safely
- All API calls include proper error handling
- The UI is responsive and follows Material Design 3 guidelines
- Form validation is implemented for all input fields

## Next Steps

1. Set up your Node.js backend API (Part 1 of the assessment)
2. Update the `baseUrl` in `constants.dart`
3. Test the complete flow: Register → Login → Create Tasks → Manage Tasks
