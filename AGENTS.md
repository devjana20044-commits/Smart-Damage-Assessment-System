# Smart Damage Assessment System - Agent Guidelines

## Project Overview

Full-stack damage assessment system: Flutter mobile app → Laravel backend with AI (Gemini) → Admin dashboard.

---

## Flutter Commands (Mobile)

```bash
# Dependencies & Run
flutter pub get
flutter run
flutter build apk
flutter build appbundle

# Code Quality
dart format .
flutter analyze
flutter test
flutter test test/unit/report_service_test.dart  # Single test
flutter test --coverage
```

**Device URLs:**
- Android Emulator: `http://10.0.2.2:8000/api`
- Physical Device: `http://<PC_IP>:8000/api`
- iOS Simulator: `http://127.0.0.1:8000/api`

---

## Laravel Commands (Backend)

```bash
# Dependencies & Setup
composer install
php artisan key:generate
php artisan migrate
php artisan serve --host=0.0.0.0 --port=8000
php artisan queue:work  # AI processing

# Code Quality
vendor/bin/pint  # PSR-12 formatting
php artisan test
php artisan test --filter ReportTest  # Single test
php artisan test --parallel

# Database
php artisan migrate:fresh --seed
php artisan make:migration create_processed_reports_table
php artisan make:model RawReport -m
```

---

## Code Style Guidelines

### Dart (Flutter)
- **Formatting**: `dart format .`, 2-space indent
- **Naming**: `camelCase` vars/methods, `PascalCase` classes, `lower_snake_case` files
- **Imports**: Dart SDK → Flutter → packages → local (use `package:`)
- **State**: Provider/Riverpod, stateless widgets, `const` constructors
- **Error Handling**: Try-catch API calls, show Snackbars, log errors

### PHP (Laravel)
- **Formatting**: `vendor/bin/pint`, PSR-12, 4-space indent
- **Naming**: `PascalCase` classes, `camelCase` methods, `snake_case` DB columns
- **Classes**: `RawReport`/`ProcessedReport` models, `ReportController`, `ProcessReportWithAI` jobs
- **Best Practices**: Eloquent relationships, Laravel validation, HTTP client for APIs, queue long tasks
- **Security**: Validate inputs, Sanctum auth, no secrets in .env, use migrations

---

## Testing Strategy

### Flutter
- Unit tests: services, providers, models (isolation)
- Widget tests: individual widgets
- Integration tests: complete flows (report submission)
- Mock API calls with Mockito

### Laravel
- Unit tests: individual methods/classes
- Feature tests: API endpoints, DB interactions
- Use RefreshDatabase trait
- Mock Gemini responses for AI job tests

---

## API Guidelines

**Authentication**: Laravel Sanctum, `Authorization: Bearer {token}`, SharedPreferences storage

**Endpoints**: `POST /login`, `POST /register`, `GET /reports`, `POST /reports`, `GET /reports/{id}`

**Response**:
```json
{"success": true, "data": {...}, "message": "..."}
```

**Error**:
```json
{"success": false, "message": "...", "errors": {...}}
```

---

## Architecture Notes

- AI processing via Laravel Queues (async)
- Images: `public/storage/reports`
- Flutter config: `lib/core/config.dart`
- Android: Add `android:usesCleartextTraffic="true"` to AndroidManifest.xml

## Current Status

Planning phase - no code yet. Follow these guidelines during implementation.
