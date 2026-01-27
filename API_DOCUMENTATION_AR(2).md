# نظام تقييم الأضرار الذكي - توثيق واجهة برمجة التطبيقات (API)

## الرابط الأساسي (Base URL)

```
http://localhost:8000/api
```

## التوثيق (Authentication)

جميع نقاط النهاية المحمية تتطلب توكن في ترويسة Authorization:

```
Authorization: Bearer YOUR_TOKEN_HERE
```

---

## نقاط النهاية (Endpoints)

### 1. فحص الاتصال (Health Check)

التحقق من أن الـ API يعمل.

**الرابط:** `GET /api`

**التوثيق:** غير مطلوب

**الطلب:**

```bash
curl -X GET http://localhost:8000/api
```

**الاستجابة (200 OK):**

```json
{
  "status": "ok",
  "message": "API is running",
  "version": "1.0.0",
  "timestamp": "2026-01-19T13:11:31+00:00"
}
```

---

### 2. تسجيل الدخول (Login)

توثيق المستخدم والحصول على توكن الوصول.

**الرابط:** `POST /api/login`

**التوثيق:** غير مطلوب

**بيانات الطلب:**

```json
{
  "email": "user@test.com",
  "password": "password"
}
```

**مثال الطلب:**

```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@test.com",
    "password": "password"
  }'
```

**الاستجابة الناجحة (200 OK):**

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

**الاستجابة (401 غير مصرح):**

```json
{
  "error": "Invalid credentials"
}
```

**الاستجابة (422 خطأ في التحقق):**

```json
{
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password field is required."]
  }
}
```

---

### 3. تسجيل الخروج (Logout)

إبطال توكن المستخدم الحالي.

**الرابط:** `POST /api/logout`

**التوثيق:** مطلوب

**الطلب:**

```bash
curl -X POST http://localhost:8000/api/logout \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

**الاستجابة (200 OK):**

```json
{
  "message": "Logged out successfully"
}
```

---

### 4. الحصول على المستخدم الحالي

الحصول على معلومات المستخدم الموثق.

**الرابط:** `GET /api/me`

**التوثيق:** مطلوب

**الطلب:**

```bash
curl -X GET http://localhost:8000/api/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

**الاستجابة (200 OK):**

```json
{
  "id": 2,
  "name": "Field Officer",
  "email": "user@test.com",
  "role": "field_user",
  "api_token": null,
  "created_at": "2026-01-19T11:19:30.000000Z",
  "updated_at": "2026-01-19T11:19:30.000000Z"
}
```

---

### 5. الحصول على تقارير المستخدم

الحصول على جميع التقارير التي أنشأها المستخدم الموثق.

**الرابط:** `GET /api/reports`

**التوثيق:** مطلوب

**الطلب:**

```bash
curl -X GET http://localhost:8000/api/reports \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

**الاستجابة (200 OK):**

```json
[
  {
    "id": 54,
    "user": {
      "id": 2,
      "name": "Field Officer"
    },
    "image_url": "http://localhost:8000/storage/reports/32.jpg",
    "location": {
      "raw": "القنيطرة - حي الأمل",
      "normalized": "القنيطرة",
      "coordinates": {
        "latitude": 33.1162,
        "longitude": 35.8268
      }
    },
    "description": {
      "raw": "أضرار في البنية التحتية للكهرباء",
      "ai_analysis": "أضرار كارثية في المباني، غير صالحة للسكن"
    },
    "damage_assessment": {
      "level": "critical",
      "status": "pending"
    },
    "created_at": "2026-01-18 16:08:42",
    "updated_at": "2026-01-19 12:36:42"
  }
]
```

---

### 6. إنشاء تقرير (Create Report)

إرسال تقرير أضرار جديد.

**الرابط:** `POST /api/reports`

**التوثيق:** مطلوب

**نوع المحتوى:** `multipart/form-data`

**معاملات الطلب:**

- `image` (ملف، مطلوب) - صورة الأضرار (الحد الأقصى 10 ميجابايت)
- `latitude` (رقم، مطلوب) - إحداثي خط العرض GPS
- `longitude` (رقم، مطلوب) - إحداثي خط الطول GPS
- `raw_location` (نص، مطلوب) - اسم الموقع كما أدخله المستخدم
- `raw_description` (نص، اختياري) - وصف إضافي (الحد الأقصى 2000 حرف)

**مثال الطلب (Flutter):**

```dart
var formData = FormData.fromMap({
  'image': await MultipartFile.fromFile(image.path),
  'latitude': '33.1162',
  'longitude': '35.8268',
  'raw_location': 'القنيطرة - حي الأمل',
  'raw_description': 'أضرار في البنية التحتية للكهرباء',
});

var response = await dio.post(
  '/api/reports',
  data: formData,
  options: Options(
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    },
  ),
);
```

**مثال الطلب (curl):**

```bash
curl -X POST http://localhost:8000/api/reports \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -F "image=@/path/to/image.jpg" \
  -F "latitude=33.1162" \
  -F "longitude=35.8268" \
  -F "raw_location=القنيطرة - حي الأمل" \
  -F "raw_description=أضرار في البنية التحتية للكهرباء"
```

**الاستجابة الناجحة (201 Created):**

```json
{
  "data": {
    "id": 57,
    "status": "pending",
    "message": "Report submitted successfully. Processing will start shortly."
  }
}
```

**الاستجابة (422 خطأ في التحقق):**

```json
{
  "errors": {
    "image": ["The image field is required."],
    "latitude": ["The latitude field is required."],
    "longitude": ["The longitude field is required."],
    "raw_location": ["The raw_location field is required."]
  }
}
```

---

### 7. الحصول على تفاصيل تقرير

الحصول على تفاصيل تقرير محدد أنشأه المستخدم الموثق.

**الرابط:** `GET /api/reports/{id}`

**التوثيق:** مطلوب

**الطلب:**

```bash
curl -X GET http://localhost:8000/api/reports/54 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

**الاستجابة (200 OK):**

```json
{
  "id": 54,
  "user": {
    "id": 2,
    "name": "Field Officer"
  },
  "image_url": "http://localhost:8000/storage/reports/32.jpg",
  "location": {
    "raw": "القنيطرة - حي الأمل",
    "normalized": "القنيطرة",
    "coordinates": {
      "latitude": 33.1162,
      "longitude": 35.8268
    }
  },
  "description": {
    "raw": "أضرار في البنية التحتية للكهرباء",
    "ai_analysis": "أضرار كارثية في المباني، غير صالحة للسكن"
  },
  "damage_assessment": {
    "level": "critical",
    "status": "pending"
  },
  "created_at": "2026-01-18 16:08:42",
  "updated_at": "2026-01-19 12:36:42"
}
```

**الاستجابة (404 غير موجود):**

```json
{
  "message": "Report not found"
}
```

---

### 8. حذف تقرير (Delete Report)

حذف تقرير محدد أنشأه المستخدم الموثق.

**الرابط:** `DELETE /api/reports/{id}`

**التوثيق:** مطلوب

**الطلب:**

```bash
curl -X DELETE http://localhost:8000/api/reports/54 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

**الاستجابة (200 OK):**

```json
{
  "message": "Report deleted successfully"
}
```

**الاستجابة (404 غير موجود):**

```json
{
  "message": "Report not found"
}
```

---

## نماذج البيانات (Data Models)

### حالة التقرير (Report Status)

- `pending` - تم إرسال التقرير، بانتظار معالجة الذكاء الاصطناعي
- `processing` - معالجة الذكاء الاصطناعي جارية
- `completed` - اكتمل تحليل الذكاء الاصطناعي
- `rejected` - تم رفض التقرير (غير صالح أو مكرر)

### مستوى الضرر (Damage Level)

- `low` - أضرار طفيفة (1-3)
- `medium` - أضرار متوسطة (4-6)
- `high` - أضرار شديدة (7-8)
- `critical` - أضرار حرجة (9-10)

### دور المستخدم (User Role)

- `admin` - مدير بصلاحيات كاملة
- `field_user` - موظل ميداني يقوم بإنشاء وإدارة التقارير

---

## رموز الأخطاء (Error Codes)

| رمز الحالة | الوصف                                |
| ---------- | ------------------------------------ |
| 200        | نجاح                                 |
| 201        | تم الإنشاء بنجاح                     |
| 401        | غير مصرح - توكن غير صالح أو مفقود    |
| 404        | غير موجود - المورد غير موجود         |
| 422        | خطأ في التحقق - بيانات طلب غير صالحة |
| 500        | خطأ في الخادم الداخلي                |

---

## بيانات الاختبار (Test Credentials)

لأغراض الاختبار، استخدم البيانات التالية:

**موظل ميداني (Field Officer):**

- البريد الإلكتروني: `user@test.com`
- كلمة المرور: `password`
- الدور: `field_user`

**مدير (Admin):**

- البريد الإلكتروني: `admin@test.com`
- كلمة المرور: `password`
- الدور: `admin`

---

## مثال التكامل مع Flutter

### تكوين API

```dart
class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid && kDebugMode) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://YOUR_SERVER_IP:8000/api';
  }
}
```

### مثال تسجيل الدخول

```dart
Future<String> login(String email, String password) async {
  final response = await dio.post(
    '${ApiConfig.baseUrl}/login',
    data: {
      'email': email,
      'password': password,
    },
  );

  final token = response.data['token'];

  // تخزين التوكن بشكل آمن
  await storage.write(key: 'auth_token', value: token);

  return token;
}
```

### مثال الحصول على التقارير

```dart
Future<List<Report>> getReports(String token) async {
  final response = await dio.get(
    '${ApiConfig.baseUrl}/reports',
    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );

  return (response.data as List)
      .map((json) => Report.fromJson(json))
      .toList();
}
```

### مثال إنشاء تقرير

```dart
Future<Report> createReport(
  String token,
  File image,
  double latitude,
  double longitude,
  String rawLocation,
  String rawDescription,
) async {
  final formData = FormData.fromMap({
    'image': await MultipartFile.fromFile(image.path),
    'latitude': latitude.toString(),
    'longitude': longitude.toString(),
    'raw_location': rawLocation,
    'raw_description': rawDescription,
  });

  final response = await dio.post(
    '${ApiConfig.baseUrl}/reports',
    data: formData,
    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      },
    ),
  );

  return Report.fromJson(response.data['data']);
}
```

### مثال حذف تقرير

```dart
Future<void> deleteReport(String token, int reportId) async {
  await dio.delete(
    '${ApiConfig.baseUrl}/reports/$reportId',
    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );
}
```

---

## ملاحظات مهمة

1. **توكن التوثيق:** يجب تضمين التوكن المستلم من تسجيل الدخول في ترويسة `Authorization` لجميع نقاط النهاية المحمية.
2. **تقارير المستخدم:** المستخدمون يمكنهم فقط رؤية وإدارة التقارير التي أنشأوها.
3. **رفع الصور:** الصور يتم تخزينها في `storage/app/public/reports/` ويمكن الوصول إليها عبر `http://localhost:8000/storage/reports/filename.jpg`.
4. **معالجة الذكاء الاصطناعي:** تحليل التقارير يتم معالجته بشكل غير متزامن عبر Laravel Queues. يتم تحديث الحالة من `pending` → `processing` → `completed`.
5. **تقييد معدل الطلبات:** يُنصح بتطبيق تقييد معدل الطلبات للاستخدام في بيئة الإنتاج.
6. **HTTPS:** استخدم HTTPS في بيئة الإنتاج للاتصال الآمن.

---

## سجل الإصدارات (Version History)

- **v1.0.0** (2026-01-19)
  - إصدار API الأولي
  - نقاط نهاية التوثيق
  - إدارة التقارير (CRUD)
  - نقطة نهاية فحص الاتصال
  - وظيفة حذف التقارير

---

## الدعم (Support)

للإبلاغ عن المشاكل أو الأسئلة، يرجى التواصل مع فريق التطوير.
