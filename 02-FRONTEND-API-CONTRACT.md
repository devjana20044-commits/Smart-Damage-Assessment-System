# 📡 العقد الرسمي للتكامل مع الـ API (Frontend API Contract)

> **تاريخ التحديث:** 2026-04-11
> **الحالة:** مبني على التدقيق الفعلي لكود الباك إند

---

## ⚙️ الإعدادات الأساسية

### Base URL

```
http://{SERVER_IP}:8000/api
```

- **للمحاكي Android:** `http://10.0.2.2:8000/api`
- **لجهاز حقيقي على نفس الشبكة:** `http://{LOCAL_IP}:8000/api`
- **الإعداد الحالي في Flutter:** قابل للتغيير من شاشة الإعدادات (AppConfig)

### المصادقة (Authentication)

```
Authorization: Bearer {TOKEN}
```

- الـ Token يُحصل عليه من `/api/login`
- مطلوب في **جميع الطلبات** ما عدا `/api/login` و `/api/` (health check)
- نوع: **Laravel Sanctum Personal Access Token**

---

## 📋 جدول نقاط النهاية (Endpoints)

| # | Method | Endpoint | Auth | Content-Type | الوصف |
|---|--------|----------|------|-------------|-------|
| 1 | `GET` | `/api/` | ❌ | JSON | فحص الخدمة |
| 2 | `POST` | `/api/login` | ❌ | JSON | تسجيل الدخول |
| 3 | `POST` | `/api/logout` | ✅ | JSON | تسجيل الخروج |
| 4 | `GET` | `/api/me` | ✅ | JSON | بيانات المستخدم الحالي |
| 5 | `GET` | `/api/reports` | ✅ | JSON | قائمة تقارير المستخدم |
| 6 | `POST` | `/api/reports` | ✅ | multipart/form-data | إنشاء تقرير جديد |
| 7 | `GET` | `/api/reports/{id}` | ✅ | JSON | تفاصيل تقرير واحد |
| 8 | `DELETE` | `/api/reports/{id}` | ✅ | JSON | حذف تقرير |

### ❌ نقاط غير متاحة حالياً (يجب تجنبها في الفرونت):

| Method | Endpoint | السبب |
|--------|----------|-------|
| `POST` | `/api/register` | **غير موجود** - لا يوجد endpoint تسجيل عبر API |
| `PUT` | `/api/reports/{id}` | **غير موجود** - لا يمكن تعديل تقرير |
| `PUT/PATCH` | `/api/profile` | **غير موجود** - لا يمكن تعديل الملف الشخصي |
| `PUT` | `/api/password` | **غير موجود** - لا يمكن تغيير كلمة المرور |

---

## 📝 تفاصيل كل Endpoint

---

### 1. 🩺 Health Check

```
GET /api/
```

**لا يحتاج مصادقة**

**استجابة ناجحة (200):**
```json
{
  "status": "ok",
  "message": "API is running",
  "version": "1.0.0",
  "timestamp": "2026-04-11T13:00:00+00:00"
}
```

**استخدام في Flutter:**
```dart
// للتحقق من اتصال الخادم
final response = await dio.get('/');
if (response.data['status'] == 'ok') {
  print('Server is connected');
}
```

---

### 2. 🔐 Login (تسجيل الدخول)

```
POST /api/login
Content-Type: application/json
```

**الطلب:**
```json
{
  "email": "user@test.com",
  "password": "password"
}
```

**استجابة ناجحة (200):**
```json
{
  "token": "15|CPmOBrrF3uas2LHIE8fROB4PhWr3HrBwBuDN9PRX27162509",
  "user": {
    "id": 2,
    "name": "Field Officer",
    "email": "user@test.com",
    "role": "field_user"
  }
}
```

**استجابة خاطئة (401):**
```json
{
  "error": "Invalid credentials"
}
```

**استجابة خطأ تحقق (422):**
```json
{
  "message": "The email field is required.",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password field is required."]
  }
}
```

> ⚠️ **ملاحظة مهمة:** الباك إند يُرجع `"error"` (وليس `"message"`) عند 401.
> يجب التعامل مع **كلا المفتاحين** في الفرونت.

**حسابات الاختبار:**
| Email | Password | Role |
|-------|----------|------|
| `admin@test.com` | `password` | admin |
| `user@test.com` | `password` | field_user |

---

### 3. 🚪 Logout (تسجيل الخروج)

```
POST /api/logout
Authorization: Bearer {TOKEN}
```

**استجابة ناجحة (200):**
```json
{
  "message": "Logged out successfully"
}
```

---

### 4. 👤 Get Current User (المستخدم الحالي)

```
GET /api/me
Authorization: Bearer {TOKEN}
```

**استجابة ناجحة (200):**
```json
{
  "id": 2,
  "name": "Field Officer",
  "email": "user@test.com",
  "email_verified_at": null,
  "role": "field_user",
  "api_token": null,
  "created_at": "2026-01-19T11:19:30.000000Z",
  "updated_at": "2026-01-19T11:19:30.000000Z"
}
```

> ⚠️ **تحذير أمني:** هذا الـ endpoint حالياً يُرجع **كل الحقول** بما فيها حقول حساسة.
> الفرونت يجب أن يستخرج فقط: `id`, `name`, `email`, `role`

**كود Flutter الصحيح:**
```dart
final response = await dio.get('/me');
final data = response.data as Map<String, dynamic>;
// استخرج فقط ما تحتاجه
final user = User(
  id: data['id'],
  name: data['name'],
  email: data['email'],
  role: data['role'] ?? 'field_user',
);
```

---

### 5. 📋 Get User Reports (قائمة التقارير)

```
GET /api/reports
Authorization: Bearer {TOKEN}
```

**استجابة ناجحة (200) - مصفوفة مباشرة:**
```json
[
  {
    "id": 54,
    "user": {
      "id": 2,
      "name": "Field Officer"
    },
    "images": [
      "http://SERVER:8000/storage/reports/images/image1.jpg",
      "http://SERVER:8000/storage/reports/images/image2.jpg"
    ],
    "pdf_url": "http://SERVER:8000/storage/reports/docs/report.pdf",
    "video_links": [
      "https://youtube.com/watch?v=example1"
    ],
    "location": {
      "raw": "حلب - حي السكري",
      "normalized": "محافظة حلب - حي السكري",
      "coordinates": {
        "latitude": 36.2018,
        "longitude": 37.1342
      }
    },
    "description": {
      "raw": "أضرار في البنية التحتية",
      "ai_analysis": "أضرار شديدة في المباني السكنية"
    },
    "damage_assessment": {
      "level": "high",
      "status": "completed"
    },
    "created_at": "2026-01-18 16:08:42",
    "updated_at": "2026-01-19 12:36:42"
  }
]
```

> 🔑 **نقطة حرجة:** الاستجابة هي **مصفوفة مباشرة `[]`** وليست ملفوفة في `{ "data": [...] }`
> هذا لأن الباك إند يستخدم `response()->json(ReportResource::collection(...))`

**كود Flutter الصحيح (المتوافق):**
```dart
final response = await dio.get('/reports');
final data = response.data;

if (data is List) {
  return data.map((json) => Report.fromJson(json)).toList();
} else {
  throw Exception('Unexpected response format');
}
```

---

### 6. ➕ Create Report (إنشاء تقرير) ⭐ الأهم

```
POST /api/reports
Authorization: Bearer {TOKEN}
Content-Type: multipart/form-data
```

#### المعاملات المطلوبة:

| الحقل | النوع | مطلوب | الحد | الوصف |
|-------|-------|-------|------|-------|
| `latitude` | number | ✅ | -90 ~ 90 | إحداثي العرض |
| `longitude` | number | ✅ | -180 ~ 180 | إحداثي الطول |
| `raw_location` | string | ✅ | 255 حرف | اسم الموقع |
| `raw_description` | string | ❌ | 2000 حرف | وصف إضافي |
| `image` | file | ❌* | 10MB | صورة واحدة (قديم) |
| `images[]` | file[] | ❌* | 10MB لكل | صور متعددة (جديد) |
| `pdf_file` | file | ❌ | 20MB | ملف PDF |
| `video_links[]` | string[] | ❌ | - | روابط فيديو |

> ⚠️ **مطلوب إما `image` أو `images[]`** - واحد على الأقل

#### قواعد التحقق الدقيقة:
```
image       → nullable|image|max:10240
images      → nullable|array
images.*    → image|mimes:jpeg,png,jpg,gif|max:10240
pdf_file    → nullable|mimes:pdf|max:20480
video_links → nullable|array
video_links.*→ nullable|url
latitude    → required|numeric|between:-90,90
longitude   → required|numeric|between:-180,180
raw_location→ required|string|max:255
raw_description → nullable|string|max:2000
```

**استجابة ناجحة (201):**
```json
{
  "data": {
    "id": 57,
    "status": "pending",
    "message": "Report submitted successfully. Processing will start shortly."
  }
}
```

> 🔑 **ملاحظة:** الاستجابة تُرجع فقط `id` و `status` و `message`.
> إذا أردت التقرير الكامل، يجب عمل **طلب إضافي** `GET /api/reports/{id}`

**استجابة خطأ تحقق (422):**
```json
{
  "errors": {
    "latitude": ["The latitude field is required."],
    "raw_location": ["The raw location field is required."]
  }
}
```

**كود Flutter صحيح:**
```dart
Future<void> createReport({
  required double latitude,
  required double longitude,
  required String rawLocation,
  String? rawDescription,
  required List<File> images,
  File? pdfFile,
  List<String>? videoLinks,
}) async {
  final Map<String, dynamic> formDataMap = {
    'latitude': latitude.toString(),
    'longitude': longitude.toString(),
    'raw_location': rawLocation,
    if (rawDescription != null && rawDescription.isNotEmpty)
      'raw_description': rawDescription,
  };

  // إضافة الصور
  if (images.isNotEmpty) {
    if (images.length == 1) {
      // صورة واحدة - استخدم image للتوافق
      formDataMap['image'] = await MultipartFile.fromFile(
        images[0].path,
        filename: images[0].path.split('/').last,
      );
    } else {
      // صور متعددة
      formDataMap['images[]'] = await Future.wait(
        images.map((img) => MultipartFile.fromFile(
          img.path,
          filename: img.path.split('/').last,
        )),
      );
    }
  }

  // إضافة PDF
  if (pdfFile != null) {
    formDataMap['pdf_file'] = await MultipartFile.fromFile(
      pdfFile.path,
      filename: pdfFile.path.split('/').last,
    );
  }

  // إضافة روابط فيديو
  if (videoLinks != null && videoLinks.isNotEmpty) {
    formDataMap['video_links[]'] = videoLinks;
  }

  final formData = FormData.fromMap(formDataMap);

  final response = await dio.post(
    '/reports',
    data: formData,
    options: Options(contentType: 'multipart/form-data'),
  );

  // الاستجابة: {"data": {"id": 57, "status": "pending", ...}}
  final reportId = response.data['data']['id'];
  print('Report created with ID: $reportId');
}
```

---

### 7. 🔍 Get Report Details (تفاصيل تقرير)

```
GET /api/reports/{id}
Authorization: Bearer {TOKEN}
```

**استجابة ناجحة (200) - كائن مباشر:**
```json
{
  "id": 54,
  "user": {
    "id": 2,
    "name": "Field Officer"
  },
  "images": ["http://SERVER:8000/storage/reports/images/img.jpg"],
  "pdf_url": null,
  "video_links": [],
  "location": {
    "raw": "حلب",
    "normalized": "محافظة حلب",
    "coordinates": {
      "latitude": 36.2018,
      "longitude": 37.1342
    }
  },
  "description": {
    "raw": "وصف المستخدم",
    "ai_analysis": "تحليل AI"
  },
  "damage_assessment": {
    "level": "high",
    "status": "completed"
  },
  "created_at": "2026-01-18 16:08:42",
  "updated_at": "2026-01-19 12:36:42"
}
```

> 🔑 **ملاحظة:** الاستجابة هي **كائن مباشر** بدون wrapping `{ "data": {...} }`
> (لأن الباك إند يستخدم `response()->json(ReportResource::make(...))`)

**استجابة خطأ (404):**
```json
{
  "message": "No query results for model [App\\Models\\Report]."
}
```

---

### 8. 🗑️ Delete Report (حذف تقرير)

```
DELETE /api/reports/{id}
Authorization: Bearer {TOKEN}
```

**استجابة ناجحة (200):**
```json
{
  "message": "Report deleted successfully"
}
```

> ملاحظة: يتم حذف جميع الملفات المرتبطة (صور + PDF) تلقائياً

---

## 🗃️ هيكل البيانات (Data Models)

### Report Status
| الحالة | الوصف |
|--------|-------|
| `pending` | قيد الانتظار - لم يبدأ AI |
| `processing` | جاري التحليل بواسطة AI |
| `completed` | تم التحليل بنجاح |
| `rejected` | فشل التحليل أو مرفوض |

### Damage Level
| المستوى | الوصف | النطاق |
|---------|-------|--------|
| `low` | طفيف | 1-3 |
| `medium` | متوسط | 4-6 |
| `high` | شديد | 7-8 |
| `critical` | حرج | 9-10 |

### User Role
| الدور | الوصف |
|-------|-------|
| `admin` | مدير - صلاحيات كاملة |
| `field_user` | مستخدم ميداني |

---

## 🔐 حالات الخطأ الشائعة

| Status | المعنى | الاستجابة | التعامل في Flutter |
|--------|--------|-----------|-------------------|
| 401 | غير مصرح | `{"error": "Invalid credentials"}` | إعادة للتسجيل |
| 403 | محظور | `{"success": false, "message": "..."}` | عرض رسالة خطأ |
| 404 | غير موجود | `{"message": "..."}` | عرض "غير موجود" |
| 422 | خطأ تحقق | `{"errors": {"field": ["msg"]}}` | عرض أخطاء الحقول |
| 500 | خطأ خادم | HTML أو JSON | "حدث خطأ، حاول لاحقاً" |

> ⚠️ **تنبيه:** خطأ 401 يستخدم مفتاح `"error"` وليس `"message"`
> بينما 403 يستخدم `"message"` ضمن `"success": false`
> يجب التعامل مع **كل الحالات** في error interceptor

---

## 📱 خريطة تدفق البيانات

```
┌─────────────┐     POST /login      ┌──────────────┐
│   Flutter    │ ──────────────────→  │   Laravel     │
│   Login      │ ←──────────────────  │   Sanctum     │
│   Screen     │   { token, user }    │   Auth        │
└─────────────┘                       └──────────────┘
       │
       │ Store token in SharedPreferences
       ▼
┌─────────────┐     GET /reports      ┌──────────────┐
│   Home       │ ──────────────────→  │   Report      │
│   Screen     │ ←──────────────────  │   Controller  │
│              │   [ReportResource]   │              │
└─────────────┘                       └──────────────┘
       │
       │ User taps "Add Report"
       ▼
┌─────────────┐    POST /reports      ┌──────────────┐
│   Add Report │ ──────────────────→  │   Store +     │
│   Screen     │ ←──────────────────  │   dispatch    │
│   (FormData) │   { id, status }     │   AI Job      │
└─────────────┘                       └──────────────┘
                                             │
                                             ▼
                                      ┌──────────────┐
                                      │   Queue       │
                                      │   Worker      │
                                      │   (Gemini AI) │
                                      └──────────────┘
                                             │
                                      status → completed/rejected
```
