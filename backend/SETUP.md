# Setup Instructions

## 1. Install Dependencies
```bash
cd backend
composer install
```

## 2. Install Laravel Packages
```bash
composer require laravel/breeze --dev
composer require laravel/sanctum
composer require guzzlehttp/guzzle
```

## 3. Install Breeze
```bash
php artisan breeze:install
```

## 4. Setup Environment
```bash
cp .env.example .env
php artisan key:generate
```

## 5. Configure Database
Edit `.env` file with your database credentials:
```
DB_DATABASE=smart_damage_assessment
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

## 6. Run Migrations and Seeders
```bash
php artisan migrate:fresh --seed
```

## 7. Create Storage Link
```bash
php artisan storage:link
```

## 8. Generate Application Key
```bash
php artisan key:generate
```

## 9. Run Queue Worker (for AI processing)
```bash
php artisan queue:work
```

## 10. Start Development Server
```bash
php artisan serve
```

## 11. Generate API Documentation
```bash
php artisan scribe:generate
```

## Test Credentials
- **Admin:** admin@test.com / password
- **Field User:** user@test.com / password

## API Endpoints
- POST /api/login - Login
- POST /api/reports - Upload report (requires authentication)
- GET /api/reports - Get user reports (requires authentication)
- GET /api/reports/{id} - Get specific report (requires authentication)
