# Role: Senior Laravel Backend Developer

**Objective:** Build a complete backend for a "Smart Damage Assessment System" using Laravel 10/11. The system receives damage reports from a mobile app, processes them using AI (Gemini), and displays them on an Admin Dashboard.

**Tech Stack:**
- Laravel 10/11
- MySQL Database
- Laravel Breeze (Blade stack) for Admin Auth
- Laravel Sanctum for API Auth
- TailwindCSS for Dashboard styling

**Task Instructions:**

1.  **Project Setup & Packages:**
    - Initialize a new Laravel project.
    - Install `laravel/breeze` and run `php artisan breeze:install` (Blade).
    - Install `google-gemini-php/client` (or simply use Laravel HTTP client) for Gemini API interaction.

2.  **Database Schema (Migrations):**
    - **Users Table:** Add `role` enum ('admin', 'user'), `api_token` (optional if using Sanctum DB driver).
    - **RawReports Table:** `id`, `user_id`, `user_input_location` (string), `user_notes` (text), `image_path` (string), `latitude`, `longitude`, `status` (pending, processed, failed).
    - **ProcessedReports Table:** `id`, `raw_report_id` (FK), `governorate` (string), `district` (string), `damage_level` (int 1-5), `damage_description` (text), `ai_confidence` (decimal).

3.  **Models & Relationships:**
    - Create models: `User`, `RawReport`, `ProcessedReport`.
    - Define relationships: User has many RawReports. RawReport has one ProcessedReport.

4.  **Seeders:**
    - Create `AdminSeeder`: Create one admin user (email: `admin@admin.com`, password: `password`).
    - Create `ReportsSeeder`: Generate dummy raw and processed reports for testing the dashboard.

5.  **API Development (Routes & Controllers):**
    - **File:** `routes/api.php`
    - **AuthController:** Implement `login` (return Sanctum token), `register`, `logout`.
    - **ReportController:**
        - `store`: Validate input, save image to `public/storage/reports`, create `RawReport` with status 'pending'. **Crucial:** Dispatch a Job named `ProcessReportWithAI`.
        - `index`: Return user's reports with their processed status.
        - `show`: Return full details.

6.  **Background Processing (Job):**
    - Create Job: `ProcessReportWithAI`.
    - Logic: Use Gemini API to analyze the text/image.
    - Prompt for AI: "Analyze this location '{location}' and note '{note}'. Standardize location to Syrian administrative levels. Estimate damage 1-5. Return JSON."
    - Save result to `ProcessedReports` and update `RawReports` status to 'processed'.

7.  **Admin Dashboard (Web Routes & Controllers):**
    - **File:** `routes/web.php` (Protect with `auth` middleware).
    - **DashboardController:**
        - Fetch stats: Total reports, High damage count, Reports by Governorate.
        - Pass data to view.
    - **Views (`resources/views/admin/`):**
        - `dashboard.blade.php`: Use Chart.js (CDN) to show a Pie Chart (Damage Levels) and Bar Chart (Governorates).
        - `reports/index.blade.php`: Table listing all reports with filters.
        - `reports/show.blade.php`: View image, raw data, and AI analysis.

**Output Required:**
Please provide the full code structure, including Migration files, Models, Controllers (API & Admin), the Job class, and the Blade views for the dashboard.