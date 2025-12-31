# Role: Senior Flutter Developer

**Objective:** Build a complete Android Flutter application for the "Smart Damage Assessment System".

**Tech Stack:**
- Flutter (Dart)
- State Management: Provider (preferred) or Riverpod.
- Networking: Dio.
- Other Packages: `geolocator` (GPS), `image_picker` (Camera), `shared_preferences` (Token storage), `google_maps_flutter` (Optional/Simple map view).

**App Flow & Structure:**

1.  **Configuration:**
    - Create `lib/core/api_constants.dart` to store the Base URL (placeholder).

2.  **Authentication:**
    - `LoginScreen`: Email/Password inputs. Save token locally upon success.
    - `RegisterScreen`: Name/Email/Password.

3.  **Home Screen:**
    - Show a list of "My Reports" using a FutureBuilder.
    - Floating Action Button (FAB) to create a new report.

4.  **Create Report Screen:**
    - Form fields: Location Name (Text), Notes (Text).
    - Buttons:
        - "Get Location": Use Geolocator to get Lat/Lng.
        - "Take Photo": Use ImagePicker to capture an image.
    - "Submit" Button: Send `FormData` to `POST /reports`.

5.  **Report Details Screen:**
    - Show the uploaded image.
    - Show status (Pending/Processed).
    - If Processed: Show the AI result (Governorate, Damage Level, Description).

**Code Requirements:**
- Create a `AuthService` and `ReportService` class for API calls using Dio.
- Implement a proper Model class (`ReportModel`) to parse JSON.
- Provide the full file structure and code for `main.dart`, `providers/`, `screens/`, `services/`, and `models/`.
- Ensure Error Handling (e.g., showing Snackbars on failure).