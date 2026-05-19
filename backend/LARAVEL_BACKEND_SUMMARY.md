# Laravel Backend - Smart Damage Assessment System

## Project Structure Created

```
backend/
├── app/
│   ├── Http/
│   │   └── Controllers/
│   │       ├── Api/
│   │       │   ├── AuthController.php        # API authentication
│   │       │   └── ReportController.php      # Report CRUD operations
│   │       └── Admin/
│   │           └── DashboardController.php  # Admin panel controller
│   ├── Jobs/
│   │   └── AnalyzeDamageJob.php             # AI processing job
│   ├── Models/
│   │   ├── User.php                         # User model
│   │   └── Report.php                       # Report model
│   └── Services/
│       └── GeminiService.php                # Google Gemini API integration
├── database/
│   ├── migrations/
│   │   └── 2024_01_01_000001_create_users_and_reports_tables.php
│   └── seeders/
│       └── UserSeeder.php
├── resources/
│   └── views/
│       └── admin/
│           ├── dashboard.blade.php          # Admin dashboard with charts
│           ├── map.blade.php                 # Interactive map view
│           └── reports.blade.php             # Reports table
├── routes/
│   ├── api.php                               # API routes
│   └── web.php                               # Web routes
├── .env.example                              # Environment variables template
└── SETUP.md                                  # Setup instructions

```

## Features Implemented

### 1. Database Schema
- **Users table**: id, name, email, password, role (admin/field_user), api_token
- **Reports table**: id, user_id, image_path, latitude, longitude, raw_location, raw_description, ai_location, ai_damage_level, ai_analysis, status

### 2. API Endpoints
- `POST /api/login` - User authentication
- `POST /api/logout` - User logout
- `GET /api/me` - Get current user
- `GET /api/reports` - Get user's reports
- `POST /api/reports` - Create new report with image upload
- `GET /api/reports/{id}` - Get specific report

### 3. AI Processing
- Asynchronous job processing using Laravel Queues
- Google Gemini API integration for damage analysis
- Automatic location normalization in Syria
- Damage level assessment (low, medium, high, critical)
- Extracted damage description from images

### 4. Admin Panel
- Dashboard with statistics
- Damage distribution chart (Chart.js)
- Interactive map view (Leaflet.js)
- Reports table with pagination
- Real-time status tracking

### 5. Security
- Laravel Sanctum for API authentication
- Role-based access control (admin/field_user)
- Input validation on all endpoints
- Secure file storage

## Key Components

### Models
- **User.php**: Authenticatable with Sanctum tokens, role-based access
- **Report.php**: Eloquent model with user relationship, type casts

### Controllers
- **AuthController**: Login, logout, and user info endpoints
- **ReportController**: Report creation and retrieval
- **DashboardController**: Admin panel views and statistics

### Jobs
- **AnalyzeDamageJob**: Queue-based AI processing with error handling

### Services
- **GeminiService**: Google Gemini API integration with image analysis

### Views
- **Dashboard**: Statistics cards, damage chart, recent reports
- **Map**: Interactive map with damage markers
- **Reports**: Paginated table with all reports

## Setup Instructions

See `backend/SETUP.md` for detailed setup steps:

1. Install dependencies
2. Configure environment
3. Run migrations and seeders
4. Start queue worker
5. Run development server

## Test Credentials

- **Admin**: admin@test.com / password
- **Field User**: user@test.com / password

## Code Standards Followed

✅ PSR-12 coding standard
✅ Laravel conventions (StudlyCase classes, camelCase methods)
✅ Type hints on all methods and properties
✅ Dependency injection in constructors
✅ Form Requests for validation
✅ API Resources for JSON responses
✅ DocBlocks for all public methods
✅ Proper error handling with logging
✅ Queue-based AI processing (non-blocking)
✅ Sanctum authentication

## Next Steps

1. Run `cd backend && composer install` to install dependencies
2. Copy `.env.example` to `.env` and configure
3. Run `php artisan migrate:fresh --seed`
4. Run `php artisan storage:link`
5. Start queue worker: `php artisan queue:work`
6. Run development server: `php artisan serve`
7. Add Google Gemini API key to `.env` file

The backend is now ready for integration with the Flutter mobile app!
