# Role: DevOps / Mobile Integration Specialist

**Objective:** Configure the connection between the Flutter Mobile App and the Local Laravel Backend. Since the environment is local development, the IP addresses vary.

**Task:**
Create a robust configuration file and a guide to ensure the Flutter app can talk to Laravel.

**Requirements:**

1.  **Dynamic Config File:**
    - Create a file `lib/core/config.dart` in Flutter.
    - Implement a mechanism to easily switch the `baseUrl`.
    - **Scenarios:**
        - **Android Emulator:** Needs `http://10.0.2.2:8000/api`.
        - **Physical Device:** Needs `http://<YOUR_PC_LOCAL_IP>:8000/api`.
        - **iOS Simulator:** Needs `http://127.0.0.1:8000/api`.

2.  **Laravel Network Config:**
    - Provide the command to serve Laravel on the local network, not just localhost.
    - Command: `php artisan serve --host=0.0.0.0 --port=8000`.

3.  **Android Manifest Config:**
    - Provide the code to add to `android/app/src/main/AndroidManifest.xml` to allow cleartext traffic (HTTP), as local development usually doesn't have HTTPS.
    - Code: `android:usesCleartextTraffic="true"`.

4.  **Action Plan for the User:**
    - Write a step-by-step guide on how the user can find their PC's IP address (Windows/Mac) and update the Flutter config file.

**Output:**
Provide the code for `lib/core/config.dart`, the XML snippet for Android Manifest, and the "How to Connect" guide.