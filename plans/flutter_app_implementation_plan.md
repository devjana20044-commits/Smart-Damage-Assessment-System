# Flutter App Implementation Plan
## Smart Damage Assessment System

---

## Overview

Complete Android Flutter application for damage reporting with AI-powered analysis. The app will integrate with a Laravel backend using REST API, featuring authentication, GPS location capture, image upload, and report tracking.

---

## Tech Stack

- **Framework:** Flutter 3.x (Dart)
- **State Management:** Provider
- **Networking:** Dio
- **Key Packages:**
  - `geolocator` - GPS location
  - `image_picker` - Camera/gallery
  - `shared_preferences` - Token storage
  - `google_maps_flutter` - Map view (optional)
  - `provider` - State management
  - `dio` - HTTP client

---

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── config.dart           # API base URL configuration
│   ├── api_constants.dart    # API endpoints
│   └── theme.dart            # App theme configuration
├── models/
│   ├── user.dart             # User model
│   └── report.dart           # Report model (raw & processed)
├── services/
│   ├── auth_service.dart     # Authentication API calls
│   ├── report_service.dart   # Reports API calls
│   ├── storage_service.dart  # SharedPreferences wrapper
│   └── dio_service.dart      # Dio configuration
├── providers/
│   ├── auth_provider.dart    # Authentication state
│   └── report_provider.dart  # Reports state
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── report/
│   │   ├── create_report_screen.dart
│   │   └── report_details_screen.dart
│   └── splash/
│       └── splash_screen.dart
├── widgets/
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── report_card.dart
│   └── loading_indicator.dart
└── utils/
    ├── constants.dart
    └── validators.dart
```

---

## Implementation Steps

### Phase 1: Project Setup & Configuration

#### 1.1 Initialize Flutter Project
- Create new Flutter project: `flutter create smart_damage_assessment`
- Navigate to project directory
- Add required dependencies to `pubspec.yaml`

#### 1.2 Configure Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  dio: ^5.4.0
  geolocator: ^10.1.0
  image_picker: ^1.0.7
  shared_preferences: ^2.2.2
  google_maps_flutter: ^2.5.3
  permission_handler: ^11.2.0
```

#### 1.3 Android Manifest Configuration
- Add `android:usesCleartextTraffic="true"` to AndroidManifest.xml
- Add permissions: INTERNET, ACCESS_FINE_LOCATION, CAMERA, WRITE_EXTERNAL_STORAGE

#### 1.4 iOS Configuration
- Add location and camera permissions to Info.plist
- Configure app transport security (allow HTTP for development)

#### 1.5 Core Configuration Files
- Create `lib/core/config.dart` with dynamic base URL switching
- Create `lib/core/api_constants.dart` with all API endpoints
- Create `lib/core/theme.dart` with app theme

---

### Phase 2: Data Models

#### 2.1 User Model
Create `lib/models/user.dart`:
- Fields: id, name, email, role
- Methods: fromJson, toJson
- Constructor with named parameters

#### 2.2 Report Model
Create `lib/models/report.dart`:
- RawReport fields: id, userId, userInputLocation, userNotes, imagePath, latitude, longitude, status, createdAt
- ProcessedReport fields: id, rawReportId, governorate, district, damageLevel, damageDescription, aiConfidence
- Methods: fromJson, toJson, isProcessed, getDamageLevelText
- Enum for status: pending, processed, failed

---

### Phase 3: Services Layer

#### 3.1 Dio Service
Create `lib/services/dio_service.dart`:
- Configure Dio instance with base URL
- Add interceptors for auth token
- Add timeout configurations
- Handle common error responses

#### 3.2 Storage Service
Create `lib/services/storage_service.dart`:
- Wrapper for SharedPreferences
- Methods: saveToken, getToken, removeToken, saveUser, getUser
- Initialize method

#### 3.3 Auth Service
Create `lib/services/auth_service.dart`:
- Method: login(email, password) - POST /login
- Method: register(name, email, password, passwordConfirmation) - POST /register
- Method: logout() - POST /logout
- Return User model or throw exceptions

#### 3.4 Report Service
Create `lib/services/report_service.dart`:
- Method: getReports() - GET /reports
- Method: getReportById(id) - GET /reports/{id}
- Method: createReport(formData) - POST /reports (multipart)
- FormData structure: user_input_location, user_notes, latitude, longitude, image
- Return list of Report models or single Report

---

### Phase 4: State Management (Providers)

#### 4.1 Auth Provider
Create `lib/providers/auth_provider.dart`:
- State: user, isAuthenticated, isLoading, errorMessage
- Methods: login, register, logout, checkAuthStatus, clearError
- Use ChangeNotifier
- Persist auth state with StorageService

#### 4.2 Report Provider
Create `lib/providers/report_provider.dart`:
- State: reports, currentReport, isLoading, errorMessage
- Methods: fetchReports, fetchReportById, createReport, clearError
- Use ChangeNotifier
- Handle loading states

---

### Phase 5: UI Screens

#### 5.1 Splash Screen
Create `lib/screens/splash/splash_screen.dart`:
- Show app logo/loading
- Check authentication status
- Navigate to Login or Home after 2 seconds
- Use Provider to check auth state

#### 5.2 Login Screen
Create `lib/screens/auth/login_screen.dart`:
- Email and password text fields
- Login button with loading state
- Navigate to Register screen
- Show error messages via SnackBar
- Call AuthProvider.login
- Navigate to Home on success

#### 5.3 Register Screen
Create `lib/screens/auth/register_screen.dart`:
- Name, email, password, password confirmation fields
- Register button with loading state
- Navigate to Login screen
- Show error messages via SnackBar
- Call AuthProvider.register
- Navigate to Home on success

#### 5.4 Home Screen
Create `lib/screens/home/home_screen.dart`:
- App bar with user name and logout button
- FutureBuilder or Consumer to show reports list
- Report cards showing: location name, status, date
- Empty state when no reports
- Floating Action Button (FAB) to create new report
- Tap on report to navigate to details
- Pull to refresh functionality
- Call ReportProvider.fetchReports

#### 5.5 Create Report Screen
Create `lib/screens/report/create_report_screen.dart`:
- Location name text field (required)
- Notes text field (optional)
- "Get Location" button:
  - Request location permissions
  - Use Geolocator to get current position
  - Display lat/lng
  - Handle errors (denied permission, timeout)
- "Take Photo" button:
  - Use ImagePicker (camera source)
  - Display preview of selected image
  - Handle camera errors
- Submit button:
  - Validate inputs
  - Create FormData with image and fields
  - Call ReportProvider.createReport
  - Show loading indicator
  - Navigate back on success
  - Show error SnackBar on failure
- Cancel button to navigate back

#### 5.6 Report Details Screen
Create `lib/screens/report/report_details_screen.dart`:
- Display uploaded image
- Show location name and coordinates
- Show user notes
- Show status badge (Pending/Processed/Failed)
- If Processed:
  - Show governorate and district
  - Show damage level (1-5 with visual indicator)
  - Show damage description
  - Show AI confidence score
- Loading state while fetching details
- Error handling

---

### Phase 6: Reusable Widgets

#### 6.1 Custom Button
Create `lib/widgets/custom_button.dart`:
- Reusable button with loading state
- Custom styling
- Disabled state handling

#### 6.2 Custom Text Field
Create `lib/widgets/custom_text_field.dart`:
- Text field with label
- Validation error display
- Password toggle for password fields

#### 6.3 Report Card
Create `lib/widgets/report_card.dart`:
- Card widget for report list
- Shows key information
- Status indicator
- Tap handler

#### 6.4 Loading Indicator
Create `lib/widgets/loading_indicator.dart`:
- Centered circular progress indicator
- Optional text message

---

### Phase 7: Main App Setup

#### 7.1 Main.dart Configuration
Create `lib/main.dart`:
- Wrap app with MultiProvider
- Configure app theme
- Set up routes
- Initialize services
- Handle app lifecycle

#### 7.2 Route Configuration
- Define named routes for all screens
- Implement route guards (auth required for home)
- Handle deep linking if needed

---

### Phase 8: Error Handling & User Feedback

#### 8.1 Error Handling
- Wrap all API calls in try-catch
- Show user-friendly error messages via SnackBar
- Log errors for debugging
- Handle network errors, timeouts, auth errors

#### 8.2 Loading States
- Show loading indicators during API calls
- Disable buttons during operations
- Provide feedback for long operations

#### 8.3 Validation
- Form validation for all inputs
- Real-time feedback
- Clear error messages

---

### Phase 9: Testing & Quality

#### 9.1 Code Quality
- Run `dart format .` for formatting
- Run `flutter analyze` for static analysis
- Fix all warnings and errors

#### 9.2 Testing
- Unit tests for services
- Widget tests for screens
- Integration tests for key flows
- Mock API calls with Mockito

#### 9.3 Testing Checklist
- [ ] Login flow works
- [ ] Registration flow works
- [ ] Logout works
- [ ] Create report with GPS works
- [ ] Create report with camera works
- [ ] Report list displays correctly
- [ ] Report details show correctly
- [ ] Error handling works
- [ ] Loading states work
- [ ] Auth persistence works

---

## API Integration Details

### Authentication Flow
```
1. User enters credentials
2. POST /login with email, password
3. Receive token and user data
4. Save token to SharedPreferences
5. Update AuthProvider state
6. Navigate to Home
```

### Report Creation Flow
```
1. User fills form fields
2. User gets GPS location (optional)
3. User takes photo (required)
4. User submits form
5. Create FormData with:
   - user_input_location: string
   - user_notes: string
   - latitude: double
   - longitude: double
   - image: File
6. POST /reports with FormData
7. Receive created report
8. Navigate back to Home
```

### Report List Flow
```
1. Home screen loads
2. GET /reports with auth token
3. Receive list of reports
4. Display in FutureBuilder/Consumer
5. User can tap to view details
```

---

## Connection Configuration Guide

### Development Scenarios

#### Android Emulator
- Base URL: `http://10.0.2.2:8000/api`
- Laravel command: `php artisan serve --host=0.0.0.0 --port=8000`
- No additional setup needed

#### Physical Android Device
- Base URL: `http://<PC_IP>:8000/api`
- Find PC IP:
  - Windows: `ipconfig` (IPv4 Address)
  - Mac/Linux: `ifconfig` or `ip addr`
- Laravel command: `php artisan serve --host=0.0.0.0 --port=8000`
- Ensure device and PC on same network

#### iOS Simulator
- Base URL: `http://127.0.0.1:8000/api`
- Laravel command: `php artisan serve --host=127.0.0.1 --port=8000`

### Config File Implementation
```dart
// lib/core/config.dart
class AppConfig {
  static const String _androidEmulator = 'http://10.0.2.2:8000/api';
  static const String _physicalDevice = 'http://192.168.1.X:8000/api'; // Update IP
  static const String _iosSimulator = 'http://127.0.0.1:8000/api';

  static String get baseUrl {
    // Auto-detect platform or allow manual override
    return _androidEmulator; // Default, update as needed
  }
}
```

---

## Security Considerations

1. **Token Storage:** Use SharedPreferences (consider flutter_secure_string for production)
2. **HTTPS:** Use HTTPS in production (cleartext only for development)
3. **Input Validation:** Validate all inputs before sending to API
4. **Error Messages:** Don't expose sensitive information in error messages
5. **Permissions:** Request permissions only when needed
6. **API Keys:** Never hardcode API keys in client code

---

## Performance Optimizations

1. **Image Compression:** Compress images before upload
2. **Caching:** Cache report data locally
3. **Lazy Loading:** Load images on demand
4. **Pagination:** Implement pagination for report list
5. **Connection Pooling:** Use Dio's connection pooling

---

## Future Enhancements

1. **Offline Mode:** Cache reports and sync when online
2. **Push Notifications:** Notify when report is processed
3. **Map Integration:** Show reports on Google Maps
4. **Draft Reports:** Save incomplete reports as drafts
5. **Report History:** Track report status changes
6. **Multiple Images:** Allow uploading multiple images
7. **Video Support:** Add video recording capability
8. **Dark Mode:** Implement dark theme support

---

## File Creation Order

1. pubspec.yaml (update dependencies)
2. lib/core/config.dart
3. lib/core/api_constants.dart
4. lib/core/theme.dart
5. lib/models/user.dart
6. lib/models/report.dart
7. lib/services/storage_service.dart
8. lib/services/dio_service.dart
9. lib/services/auth_service.dart
10. lib/services/report_service.dart
11. lib/providers/auth_provider.dart
12. lib/providers/report_provider.dart
13. lib/widgets/custom_button.dart
14. lib/widgets/custom_text_field.dart
15. lib/widgets/report_card.dart
16. lib/widgets/loading_indicator.dart
17. lib/screens/splash/splash_screen.dart
18. lib/screens/auth/login_screen.dart
19. lib/screens/auth/register_screen.dart
20. lib/screens/home/home_screen.dart
21. lib/screens/report/create_report_screen.dart
22. lib/screens/report/report_details_screen.dart
23. lib/main.dart

---

## Testing Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk

# Build App Bundle
flutter build appbundle

# Format code
dart format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Run specific test
flutter test test/unit/report_service_test.dart

# Run tests with coverage
flutter test --coverage
```

---

## Summary

This plan provides a complete roadmap for building the Flutter mobile application with:
- Clean architecture (separation of concerns)
- Provider state management
- Robust error handling
- User-friendly UI
- Proper API integration
- Configuration flexibility for different development scenarios
- Quality assurance through testing

The implementation follows Flutter best practices and the project's coding standards defined in AGENTS.md.
