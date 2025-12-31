# Role: Technical Writer / Backend Lead

**Objective:** Create comprehensive API Documentation for the "Smart Damage Assessment System" developed in the previous step. This documentation will be used to build the Flutter mobile application.

**Base URL:** `http://YOUR_LOCAL_IP:8000/api`

**Requirements:**

1.  **Authentication:**
    - Document `POST /login`: Params (email, password), Response (token, user object).
    - Document `POST /register`: Params (name, email, password, password_confirmation).

2.  **Reports Management:**
    - Document `POST /reports`:
        - Header: `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`.
        - Body: `user_input_location` (string), `user_notes` (string), `latitude` (double), `longitude` (double), `image` (File).
    - Document `GET /reports`:
        - Response: List of reports with status (pending/processed).
    - Document `GET /reports/{id}`:
        - Response: Detailed view including the AI analysis (if available).

**Output Format:**
Please provide the documentation in Markdown format, including Request examples (JSON/FormData) and Response examples (Success/Error) for each endpoint.