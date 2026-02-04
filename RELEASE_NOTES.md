# **Final Backend Release Note & API Update Report**

**To:** Mobile App (Frontend) Team  
**From:** Senior Backend Lead  
**Date:** January 27, 2026  
**Subject:** Backend Stability & Multimedia Feature Release

---

## **1. Executive Summary**

The backend of the Smart Damage Assessment System is now **fully stable and ready for integration**. The critical bug causing `500 Internal Server Error` has been resolved, and a major new feature – **Multimedia Support** – has been deployed. All endpoints are functional, encoding (UTF‑8) for Arabic text is verified, and integration tests with realistic Damascus‑based data have passed successfully.

## **2. The Fix (Technical)**

The `500 Internal Server Error` originated from a type‑mismatch in the `AnalyzeDamageJob` queue processor (`int` vs `string` in the `$tries` property). The issue has been corrected by ensuring proper type casting and queue configuration. **Queue processing is now stable**, and the job dispatches without throwing server errors.

## **3. API Changes (Frontend Action Required)**

### **Updated Endpoint: `POST /api/reports`**

The endpoint now accepts **multiple media types** instead of a single image. The request format is backward‑compatible (the old `image` field is still supported), but we strongly recommend migrating to the new structure to leverage the multimedia capabilities.

#### **Request Parameters (Multipart/Form‑Data)**

| Field             | Type            | Required             | Description                                                    |
| ----------------- | --------------- | -------------------- | -------------------------------------------------------------- |
| `images[]`        | `Array<File>`   | **Yes** (or `image`) | One or more damage images (JPEG, PNG, GIF). Each file ≤10 MB.  |
| `pdf_file`        | `File`          | No                   | A PDF document (≤20 MB).                                       |
| `video_links[]`   | `Array<String>` | No                   | Array of video URLs (YouTube, etc.). Each must be a valid URL. |
| `latitude`        | `number`        | Yes                  | GPS latitude.                                                  |
| `longitude`       | `number`        | Yes                  | GPS longitude.                                                 |
| `raw_location`    | `string`        | Yes                  | Location name in Arabic (e.g., "دمشق – شارع الفردوس").         |
| `raw_description` | `string`        | No                   | Additional description (max 2000 characters).                  |

#### **Flutter/Dio Code Snippet**

```dart
import 'dart:io';
import 'package:dio/dio.dart';

Future<void> uploadReport({
  required List<File> images,
  File? pdfFile,
  List<String>? videoLinks,
  required double latitude,
  required double longitude,
  required String rawLocation,
  String? rawDescription,
}) async {
  final dio = Dio();
  final formData = FormData();

  // 1. Images (multiple)
  for (var i = 0; i < images.length; i++) {
    formData.files.add(
      MapEntry(
        'images[]',
        await MultipartFile.fromFile(images[i].path),
      ),
    );
  }

  // 2. PDF (optional)
  if (pdfFile != null) {
    formData.files.add(
      MapEntry(
        'pdf_file',
        await MultipartFile.fromFile(pdfFile.path),
      ),
    );
  }

  // 3. Video links (optional)
  if (videoLinks != null && videoLinks.isNotEmpty) {
    for (var link in videoLinks) {
      formData.fields.add(MapEntry('video_links[]', link));
    }
  }

  // 4. Required fields
  formData.fields.addAll([
    MapEntry('latitude', latitude.toString()),
    MapEntry('longitude', longitude.toString()),
    MapEntry('raw_location', rawLocation),
    if (rawDescription != null) MapEntry('raw_description', rawDescription),
  ]);

  // 5. Send request
  final response = await dio.post(
    'http://10.28.57.151:8000/api/reports',
    data: formData,
    options: Options(
      headers: {
        'Authorization': 'Bearer $yourToken',
        'Accept': 'application/json',
      },
    ),
  );

  print('Report created: ${response.data}');
}
```

## **4. Response Format**

The response remains structurally unchanged, but the underlying data model now includes the new multimedia fields.

**Success Response (201 Created):**

```json
{
  "data": {
    "id": 123,
    "status": "pending",
    "message": "Report submitted successfully. Processing will start shortly."
  }
}
```

**Updated Report Object (when fetching a report):**

```json
{
  "id": 123,
  "user": { "id": 1, "name": "اسم المستخدم" },
  "images": [
    "http://10.28.57.151:8000/storage/reports/images/abc.jpg",
    "http://10.28.57.151:8000/storage/reports/images/def.jpg"
  ],
  "pdf_file": "http://10.28.57.151:8000/storage/reports/docs/report123.pdf",
  "video_links": ["https://youtu.be/xyz", "https://youtu.be/abc"],
  "raw_location": "دمشق – شارع الفردوس",
  "raw_description": "تضرر في المباني السكنية بسبب القصف",
  "ai_damage_level": "high",
  "ai_location": "دمشق",
  "ai_analysis": "أضرار جسيمة في المباني، تحتاج إلى إعادة بناء جزئية",
  "status": "completed",
  "created_at": "2026-01-27T14:30:00Z",
  "updated_at": "2026-01-27T14:35:00Z"
}
```

## **5. Next Steps**

**For the Frontend Team:**

1. **Update the report‑upload logic** to use `images[]` (array) instead of the singular `image` field.
2. **Optionally add support** for PDF uploads and video‑link arrays.
3. **Adapt your UI** to handle multiple images and the new media types when displaying report details.
4. **Test with the provided endpoints** using realistic Arabic data (locations like "دمشق", "حلب") to confirm UTF‑8 encoding and multimedia handling.

## **6. Additional Notes**

- **Backward Compatibility:** The old `image` field is still accepted, but it will be stored as the first element of the `images` array.
- **Admin Map Enhancement:** The admin map (`/admin/map`) now displays all uploaded images, a PDF download button, and video links inside each report’s popup.
- **Performance:** The system automatically processes multimedia reports through the same AI pipeline (Gemini) without blocking the user request.

---

**Backend is now stable and feature‑complete. We are ready to support your integration efforts.**  
Please reach out if you encounter any issues or need further clarification.

— Backend Team
