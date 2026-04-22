# 🔌 دليل تكامل الفرونت إند مع الـ API
# Frontend API Integration Guide

> **المشروع:** Smart Damage Assessment System
> **إصدار الـ API:** v1.0
> **Base URL:** `http://{SERVER_IP}:8000/api`
> **Authentication:** Bearer Token (Laravel Sanctum)
> **Content-Type:** `application/json` (ما عدا رفع الملفات: `multipart/form-data`)

---

## 📌 معلومات عامة

### Base URL Configuration (Flutter)
```dart
class ApiConfig {
  // للمحاكي Android
  static const String emulatorUrl = 'http://10.0.2.2:8000/api';
  // لجهاز حقيقي (غيّر الـ IP)
  static const String deviceUrl = 'http://192.168.1.X:8000/api';

  static String get baseUrl {
    if (Platform.isAndroid && kDebugMode) {
      return emulatorUrl;
    }
    return deviceUrl;
  }
}
```

### Headers المطلوبة

| Header | القيمة | مطلوب؟ |
|--------|--------|--------|
| `Accept` | `application/json` | ✅ دائماً |
| `Content-Type` | `application/json` | ✅ للطلبات العادية |
| `Content-Type` | `multipart/form-data` | ✅ عند رفع ملفات |
| `Authorization` | `Bearer {token}` | ✅ للـ endpoints المحمية |

### Dio Interceptor Setup (Flutter)
```dart
final dio = Dio(BaseOptions(
  baseUrl: ApiConfig.baseUrl,
  connectTimeout: const Duration(seconds: 15),
  receiveTimeout: const Duration(seconds: 15),
  headers: {
    'Accept': 'application/json',
  },
));

// إضافة التوكن تلقائياً
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await SecureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
  onError: (error, handler) {
    if (error.response?.statusCode == 401) {
      // التوكن منتهي - أعد توجيه لتسجيل الدخول
      NavigationService.navigateToLogin();
    }
    return handler.next(error);
  },
));
```

---

## 🔐 1. المصادقة (Authentication)

### 1.1 تسجيل الدخول

```
POST /api/login
Content-Type: application/json
(بدون Authorization header)
```

**Request Body:**
```json
{
  "email": "user@test.com",
  "password": "password"
}
```

**Success Response (200):**
```json
{
  "token": "1|abc123xyz...",
  "user": {
    "id": 1,
    "name": "Field Officer",
    "email": "user@test.com",
    "role": "field_user"
  }
}
```

**Error Response (401):**
```json
{
  "error": "Invalid credentials"
}
```

**Error Response (422 - Validation):**
```json
{
  "message": "The email field is required.",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password field is required."]
  }
}
```

**Flutter Implementation:**
```dart
Future<LoginResult> login(String email, String password) async {
  try {
    final response = await dio.post('/login', data: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final token = response.data['token'];
      final user = response.data['user'];

      // حفظ التوكن في التخزين الآمن
      await SecureStorage.saveToken(token);
      await SecureStorage.saveUser(jsonEncode(user));

      return LoginResult.success(user);
    }
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      return LoginResult.error('بيانات الدخول غير صحيحة');
    }
    if (e.response?.statusCode == 422) {
      return LoginResult.validationError(e.response?.data['errors']);
    }
    return LoginResult.error('خطأ في الاتصال');
  }
}
```

> ⚠️ **تنبيه مهم:** خزّن التوكن في `flutter_secure_storage` وليس في `SharedPreferences`.

---

### 1.2 تسجيل الخروج

```
POST /api/logout
Authorization: Bearer {token}
```

**Success Response (200):**
```json
{
  "message": "Logged out successfully"
}
```

---

### 1.3 جلب بيانات المستخدم الحالي

```
GET /api/me
Authorization: Bearer {token}
```

**Success Response (200):**
```json
{
  "id": 1,
  "name": "Field Officer",
  "email": "user@test.com",
  "role": "field_user",
  "profile_image": "http://server/storage/profiles/xxx.jpg",
  "created_at": "2026-04-11T10:00:00.000000Z"
}
```

> ⚠️ **ملاحظة:** `profile_image` قد يكون `null` إذا لم يرفع المستخدم صورة.

---

## 📋 2. إدارة التقارير (Reports)

### 2.1 جلب جميع التقارير

```
GET /api/reports
Authorization: Bearer {token}
```

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "user": {
        "id": 1,
        "name": "Field Officer"
      },
      "images": [
        "http://server/storage/reports/images/abc123.jpg",
        "http://server/storage/reports/images/def456.jpg"
      ],
      "pdf_url": "http://server/storage/reports/docs/report.pdf",
      "video_links": [
        "https://youtube.com/watch?v=xxx"
      ],
      "location": {
        "raw": "حلب السكري",
        "normalized": "محافظة حلب - حي السكري",
        "coordinates": {
          "latitude": 36.2018,
          "longitude": 37.1342
        }
      },
      "description": {
        "raw": "أضرار في المبنى السكني",
        "ai_analysis": "أضرار جسيمة في الهيكل الإنشائي..."
      },
      "damage_assessment": {
        "level": "high",
        "status": "completed"
      },
      "created_at": "2026-04-11 10:30:00",
      "updated_at": "2026-04-11 10:35:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 3,
    "per_page": 20,
    "total": 50
  }
}
```

**Flutter Model:**
```dart
class ReportModel {
  final int id;
  final UserBrief user;
  final List<String> images;
  final String? pdfUrl;
  final List<String> videoLinks;
  final LocationData location;
  final DescriptionData description;
  final DamageAssessment damageAssessment;
  final String createdAt;
  final String updatedAt;

  ReportModel.fromJson(Map<String, dynamic> json) :
    id = json['id'],
    user = UserBrief.fromJson(json['user']),
    images = List<String>.from(json['images'] ?? []),
    pdfUrl = json['pdf_url'],
    videoLinks = List<String>.from(json['video_links'] ?? []),
    location = LocationData.fromJson(json['location']),
    description = DescriptionData.fromJson(json['description']),
    damageAssessment = DamageAssessment.fromJson(json['damage_assessment']),
    createdAt = json['created_at'],
    updatedAt = json['updated_at'];
}

class LocationData {
  final String raw;
  final String normalized;
  final double latitude;
  final double longitude;

  LocationData.fromJson(Map<String, dynamic> json) :
    raw = json['raw'] ?? '',
    normalized = json['normalized'] ?? '',
    latitude = (json['coordinates']?['latitude'] ?? 0).toDouble(),
    longitude = (json['coordinates']?['longitude'] ?? 0).toDouble();
}

class DescriptionData {
  final String? raw;
  final String? aiAnalysis;

  DescriptionData.fromJson(Map<String, dynamic> json) :
    raw = json['raw'],
    aiAnalysis = json['ai_analysis'];
}

class DamageAssessment {
  final String? level; // low, medium, high, critical
  final String status; // pending, processing, completed, rejected

  DamageAssessment.fromJson(Map<String, dynamic> json) :
    level = json['level'],
    status = json['status'] ?? 'pending';
}
```

---

### 2.2 جلب تقرير واحد

```
GET /api/reports/{id}
Authorization: Bearer {token}
```

**Success Response (200):**
```json
{
  "id": 1,
  "user": { "id": 1, "name": "Field Officer" },
  "images": [...],
  "pdf_url": "...",
  "video_links": [...],
  "location": {...},
  "description": {...},
  "damage_assessment": {...},
  "created_at": "2026-04-11 10:30:00",
  "updated_at": "2026-04-11 10:35:00"
}
```

> ⚠️ **ملاحظة:** الرد لتقرير واحد يأتي **بدون** مفتاح `data` wrapper (مباشرة كـ object). هذا سلوك `ReportResource::make()`.

**Error Response (404):**
```json
{
  "message": "No query results for model [App\\Models\\Report]."
}
```

> ⚠️ المستخدم يمكنه فقط رؤية تقاريره الخاصة. محاولة الوصول لتقرير مستخدم آخر ستعطي 404.

---

### 2.3 إنشاء تقرير جديد ⭐ (الأهم)

```
POST /api/reports
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request Body (FormData):**

| الحقل | النوع | مطلوب؟ | القيود | مثال |
|-------|-------|--------|--------|------|
| `image` | File | ❌ | image, max 10MB | صورة واحدة (نظام قديم) |
| `images[]` | File[] | ❌ | image, jpeg/png/jpg/gif, max 10MB لكل صورة | صور متعددة (نظام جديد) |
| `pdf_file` | File | ❌ | pdf, max 20MB | ملف PDF |
| `video_links[]` | String[] | ❌ | URL صالح | روابط يوتيوب |
| `latitude` | Number | ✅ | -90 إلى 90 | `36.2018` |
| `longitude` | Number | ✅ | -180 إلى 180 | `37.1342` |
| `raw_location` | String | ✅ | max 255 حرف | `حلب السكري` |
| `raw_description` | String | ❌ | max 2000 حرف | `أضرار في المبنى` |

**Success Response (201):**
```json
{
  "data": {
    "id": 15,
    "status": "pending",
    "message": "Report submitted successfully. Processing will start shortly."
  }
}
```

**Error Response (422 - Validation):**
```json
{
  "errors": {
    "latitude": ["The latitude field is required."],
    "raw_location": ["The location field is required."],
    "images.0": ["The images.0 must be an image."]
  }
}
```

**Flutter Implementation:**
```dart
Future<int?> submitReport({
  required List<File> images,
  File? pdfFile,
  List<String>? videoLinks,
  required double latitude,
  required double longitude,
  required String rawLocation,
  String? rawDescription,
}) async {
  try {
    final formData = FormData();

    // إضافة الصور
    for (int i = 0; i < images.length; i++) {
      formData.files.add(MapEntry(
        'images[]',
        await MultipartFile.fromFile(
          images[i].path,
          filename: 'image_$i.jpg',
        ),
      ));
    }

    // إضافة PDF
    if (pdfFile != null) {
      formData.files.add(MapEntry(
        'pdf_file',
        await MultipartFile.fromFile(pdfFile.path),
      ));
    }

    // إضافة روابط الفيديو
    if (videoLinks != null) {
      for (final link in videoLinks) {
        if (link.isNotEmpty) {
          formData.fields.add(MapEntry('video_links[]', link));
        }
      }
    }

    // إضافة البيانات النصية
    formData.fields.addAll([
      MapEntry('latitude', latitude.toString()),
      MapEntry('longitude', longitude.toString()),
      MapEntry('raw_location', rawLocation),
      if (rawDescription != null)
        MapEntry('raw_description', rawDescription),
    ]);

    final response = await dio.post('/reports', data: formData);

    if (response.statusCode == 201) {
      return response.data['data']['id'];
    }
  } on DioException catch (e) {
    // معالجة الأخطاء
    throw _handleError(e);
  }
  return null;
}
```

> ⚠️ **تنبيه:** استخدم `images[]` (مع أقواس مربعة) لرفع صور متعددة. إذا رفعت صورة واحدة فقط، يمكنك استخدام `image` (بدون أقواس) للتوافق مع النظام القديم.

---

### 2.4 حذف تقرير

```
DELETE /api/reports/{id}
Authorization: Bearer {token}
```

**Success Response (200):**
```json
{
  "message": "Report deleted successfully"
}
```

---

## 👨‍💼 3. Admin API (إدارة المستخدمين)

> ⚠️ هذه الـ endpoints تتطلب حساب admin. ستحصل على 403 إذا كان المستخدم `field_user`.

### 3.1 جلب قائمة المستخدمين

```
GET /api/admin/users?page=1&per_page=15&search=ahmed&role=field_user
Authorization: Bearer {admin_token}
```

**Query Parameters:**

| Parameter | النوع | الوصف |
|-----------|-------|-------|
| `page` | int | رقم الصفحة |
| `per_page` | int | عدد النتائج لكل صفحة (افتراضي 15) |
| `search` | string | بحث بالاسم أو البريد |
| `role` | string | فلتر بالدور: `admin` أو `field_user` |
| `sort_by` | string | ترتيب حسب: `created_at`, `name`, `email` |
| `sort_order` | string | `asc` أو `desc` |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Admin User",
      "email": "admin@test.com",
      "role": "admin",
      "created_at": "2026-04-11T10:00:00.000000Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 15,
    "total": 2
  }
}
```

### 3.2 إنشاء مستخدم جديد

```
POST /api/admin/users
Authorization: Bearer {admin_token}
Content-Type: application/json
```

```json
{
  "name": "New User",
  "email": "new@test.com",
  "password": "password123",
  "role": "field_user"
}
```

### 3.3 إحصائيات المستخدمين

```
GET /api/admin/users/statistics
Authorization: Bearer {admin_token}
```

```json
{
  "success": true,
  "data": {
    "total_users": 10,
    "admins": 2,
    "field_users": 8,
    "users_with_reports": 5
  }
}
```

---

## 🔄 4. دورة حياة التقرير (Report Lifecycle)

```
┌──────────┐     ┌─────────────┐     ┌───────────┐     ┌───────────┐
│ PENDING  │────▶│ PROCESSING  │────▶│ COMPLETED │  أو │ REJECTED  │
│           │     │  (AI يحلل)   │     │ (تم التحليل)│     │ (فشل AI)  │
└──────────┘     └─────────────┘     └───────────┘     └───────────┘
```

| الحالة | المعنى | لون مقترح |
|--------|--------|-----------|
| `pending` | في انتظار المعالجة | 🟡 أصفر |
| `processing` | الذكاء الاصطناعي يحلل | 🔵 أزرق |
| `completed` | تم التحليل بنجاح | 🟢 أخضر |
| `rejected` | فشل التحليل | 🔴 أحمر |

### مستويات الضرر (Damage Levels)

| المستوى | المعنى | لون مقترح |
|---------|--------|-----------|
| `low` | أضرار طفيفة | 🟢 أخضر |
| `medium` | أضرار متوسطة | 🟡 أصفر |
| `high` | أضرار جسيمة | 🟠 برتقالي |
| `critical` | أضرار كارثية | 🔴 أحمر |

---

## ⚠️ 5. معالجة الأخطاء (Error Handling)

### أكواد HTTP الشائعة

| الكود | المعنى | الإجراء في Flutter |
|-------|--------|-------------------|
| `200` | نجاح | عرض البيانات |
| `201` | تم الإنشاء | عرض رسالة نجاح |
| `401` | غير مصادق | إعادة توجيه لتسجيل الدخول |
| `403` | غير مصرح | عرض "لا تملك صلاحية" |
| `404` | غير موجود | عرض "غير موجود" |
| `422` | خطأ في البيانات | عرض رسائل الخطأ تحت الحقول |
| `429` | طلبات كثيرة | عرض "حاول لاحقاً" |
| `500` | خطأ في السيرفر | عرض "خطأ في السيرفر" |

### Flutter Error Handler:
```dart
String _handleError(DioException e) {
  switch (e.response?.statusCode) {
    case 401:
      return 'الجلسة منتهية. يرجى تسجيل الدخول مجدداً';
    case 403:
      return 'لا تملك صلاحية لهذا الإجراء';
    case 404:
      return 'المورد غير موجود';
    case 422:
      final errors = e.response?.data['errors'] as Map?;
      if (errors != null) {
        return errors.values.first.first;
      }
      return 'بيانات غير صالحة';
    case 429:
      return 'طلبات كثيرة. حاول بعد قليل';
    case 500:
      return 'خطأ في السيرفر. حاول لاحقاً';
    default:
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'انتهت مهلة الاتصال';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'لا يوجد اتصال بالإنترنت';
      }
      return 'خطأ غير متوقع';
  }
}
```

---

## 📡 6. الاتصال الحقيقي (Real Device Connection)

### خطوات الربط:

1. **تأكد أن اللابتوب والموبايل على نفس شبكة WiFi**

2. **اعرف IP اللابتوب:**
   ```bash
   ipconfig  # على Windows
   # ابحث عن IPv4 Address: 192.168.1.X
   ```

3. **شغّل Laravel على كل الشبكات:**
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```

4. **حدّث `ApiConfig` في Flutter:**
   ```dart
   static const String deviceUrl = 'http://192.168.1.X:8000/api';
   ```

5. **تأكد من السماح في جدار الحماية:**
   ```bash
   # Windows Firewall - السماح بالمنفذ 8000
   netsh advfirewall firewall add rule name="Laravel" dir=in action=allow protocol=TCP localport=8000
   ```

### Android Network Security (مطلوب):

في ملف `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

في ملف `android/app/src/main/res/xml/network_security_config.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">192.168.1.0/24</domain>
    </domain-config>
</network-security-config>
```

---

## 🗄️ 7. مخطط قاعدة البيانات (للمرجعية)

### جدول `users`

| الحقل | النوع | وصف |
|-------|-------|------|
| `id` | bigint | المعرف |
| `name` | string | الاسم |
| `email` | string (unique) | البريد |
| `email_verified_at` | timestamp (nullable) | وقت التحقق |
| `profile_image` | string (nullable) | مسار صورة الملف الشخصي |
| `password` | string | كلمة المرور (مشفرة) |
| `role` | enum | `admin` أو `field_user` |
| `api_token` | string (nullable) | توكن قديم (لا يُستخدم) |

### جدول `reports`

| الحقل | النوع | وصف |
|-------|-------|------|
| `id` | bigint | المعرف |
| `user_id` | foreign key | مرجع المستخدم |
| `image_path` | string (nullable) | مسار الصورة القديمة |
| `images` | json (nullable) | مصفوفة مسارات الصور الجديدة |
| `pdf_file` | string (nullable) | مسار ملف PDF |
| `video_links` | json (nullable) | مصفوفة روابط الفيديو |
| `latitude` | decimal(10,8) | خط العرض |
| `longitude` | decimal(11,8) | خط الطول |
| `raw_location` | string | الموقع كما كتبه المستخدم |
| `raw_description` | text (nullable) | وصف المستخدم |
| `ai_location` | string (nullable) | الموقع بعد تصحيح AI |
| `ai_damage_level` | enum (nullable) | `low/medium/high/critical` |
| `ai_analysis` | text (nullable) | تحليل AI المفصل |
| `status` | enum | `pending/processing/completed/rejected` |
| `created_at` | timestamp | وقت الإنشاء |
| `updated_at` | timestamp | وقت التحديث |

---

## 🧪 8. حسابات الاختبار

| الدور | البريد | كلمة المرور |
|-------|--------|-------------|
| Admin | `admin@test.com` | `password` |
| Field User | `user@test.com` | `password` |

---

## 📝 9. ملاحظات هامة للمطور

1. **التوقيت:** AI processing يأخذ 5-30 ثانية. لا تنتظره. استخدم polling كل 5 ثوانٍ لتحديث حالة التقرير.

2. **الصور:** كل URLs الصور تبدأ بـ `http://server/storage/...`. تأكد من إظهارها بشكل صحيح.

3. **Null Safety:** حقول AI كلها `nullable`. فقط بعد حالة `completed` ستجد بيانات فيها.

4. **التوافق:** الـ API يدعم `image` (صورة واحدة - قديم) و `images[]` (صور متعددة - جديد). استخدم الجديد دائماً.

5. **Pagination:** API التقارير يدعم pagination. استخدم `?page=1&per_page=20`.

6. **الأخطاء العربية:** بعض رسائل الخطأ تأتي بالإنجليزية من Laravel. قم بترجمتها محلياً.
