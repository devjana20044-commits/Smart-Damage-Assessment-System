# 🔧 إصلاحات مطلوبة في كود Flutter الحالي

> **تاريخ التدقيق:** 2026-04-11
> **المسار:** `frontend/smart_damage_assessment/`

---

## 🔴 مشاكل حرجة (MUST FIX)

---

### 1. ❌ `auth_service.dart` → `register()` يستدعي endpoint غير موجود

**الملف:** `lib/services/auth_service.dart:80`
**المشكلة:** يستدعي `POST /api/register` لكن هذا الـ endpoint **غير موجود في الباك إند**

```dart
// ❌ الكود الحالي
final response = await _dioService.dio.post(
  ApiConstants.register,  // '/register' → غير موجود!
  data: {...},
);
```

**الحل:**
- **خيار 1 (سريع):** تعطيل زر التسجيل في UI + إضافة تعليق واضح
- **خيار 2 (أفضل):** طلب من فريق الباك إند إضافة `POST /api/register`

```dart
// ✅ الحل المؤقت
Future<User> register({...}) async {
  throw UnimplementedError(
    'Registration via API is not available. '
    'Contact admin to create accounts.'
  );
}
```

---

### 2. ❌ `api_constants.dart` → ينقصه ثوابت الوسائط المتعددة

**الملف:** `lib/core/api_constants.dart`
**المشكلة:** لا يحتوي على ثوابت `images[]`, `pdf_file`, `video_links[]`

```dart
// ❌ الكود الحالي - فقط image واحدة
static const String image = 'image';

// ✅ يجب إضافة:
static const String images = 'images[]';
static const String pdfFile = 'pdf_file';
static const String videoLinks = 'video_links[]';
```

---

### 3. ❌ `report_service.dart` → `createReport()` يحاول جلب التقرير فوراً بعد الإنشاء

**الملف:** `lib/services/report_service.dart:89-90`
**المشكلة:** بعد إنشاء التقرير، يستدعي `getReportById(reportId)` لجلب التفاصيل الكاملة.
لكن التقرير يكون `pending` ولم يُعالج بعد. هذا قد يسبب مشاكل إذا الباك إند يحتاج وقت لمعالجة.

```dart
// ❌ الكود الحالي
final reportId = data['id'] as int;
return await getReportById(reportId);  // طلب إضافي غير ضروري

// ✅ الحل الأفضل: إرجاع Report مبسط بدون طلب إضافي
return Report.fromCreateResponse(data);
// أو إرجاع Map فقط:
// return {'id': reportId, 'status': 'pending'};
```

---

## 🟠 مشاكل عالية (SHOULD FIX)

---

### 4. ⚠️ `report.dart` → parsing خطأ في `image_url`

**الملف:** `lib/models/report.dart:277`
**المشكلة:** يبحث عن مفتاح `image_url` لكن API الحالي لا يُرسله — يرسل `images[]` فقط

```dart
// ❌ الكود الحالي
imageUrl: json['image_url'] as String? ?? legacyImageUrl,

// ✅ الإصلاح: لا تعتمد على image_url أبداً
imageUrl: legacyImageUrl,  // أول صورة من images[]
```

**هيكل ReportResource الفعلي من الباك إند:**
```json
{
  "id": 1,
  "user": {...},
  "images": ["http://..."],    // ← هذا هو المفتاح الصحيح
  "pdf_url": null,
  "video_links": [],
  "location": {...},
  "description": {...},
  "damage_assessment": {...},
  "created_at": "...",
  "updated_at": "..."
}
```

> ⚠️ **لاحظ:** لا يوجد `image_url` في الاستجابة! فقط `images` (مصفوفة)

---

### 5. ⚠️ `dio_service.dart` → Singleton pattern قد يسبب مشاكل عند تغيير URL

**الملف:** `lib/services/dio_service.dart:16-22`
**المشكلة:** `getInstance()` يتحقق `if (_instance == null)` فقط.
عند تغيير URL من شاشة Settings، يجب استدعاء `resetInstance()` ثم إعادة تهيئة **كل** الخدمات المعتمدة.

```dart
// ⚠️ المشكلة: بعد تغيير URL، الـ AuthService و ReportService
// لا زالوا يستخدمون الـ DioService القديم!

// ✅ الحل: عند تغيير البيانات في Settings:
DioService.resetInstance();
// ثم يجب إعادة تهيئة:
final dioService = await DioService.getInstance();
// وتحديث كل Provider يستخدم DioService
```

---

### 6. ⚠️ `user.dart` → لا يتعامل مع الحقول الإضافية من `/me`

**الملف:** `lib/models/user.dart:16-31`
**المشكلة:** `/api/me` يرجع حقول إضافية (مثل `created_at`, `updated_at`, `profile_image`)
لكن `User.fromJson()` يتجاهلها — وهذا **صحيح وآمن**.

**ملاحظة:** الكود الحالي يتعامل بشكل صحيح مع هذا. لا حاجة لتغيير.

---

### 7. ⚠️ `report_service.dart` → ثلاث methods لإنشاء تقرير (فوضى)

**الملف:** `lib/services/report_service.dart`
**المشكلة:** يوجد 3 methods مختلفة:
1. `createReport()` - صورة واحدة
2. `createReportFromXFile()` - XFile support
3. `createReportWithMultimedia()` - صور متعددة + PDF + فيديو

**الحل:** دمج الثلاثة في method واحدة:

```dart
// ✅ method واحدة موحدة
Future<Map<String, dynamic>> createReport({
  required String rawLocation,
  String? rawDescription,
  required double latitude,
  required double longitude,
  List<File>? images,
  File? singleImage,  // للتوافق القديم
  File? pdfFile,
  List<String>? videoLinks,
}) async {
  // ...
}
```

---

## 🟡 مشاكل متوسطة (NICE TO FIX)

---

### 8. 💡 `main.dart` → Routes معلقة

**الملف:** `lib/main.dart:87-94`
**المشكلة:** routes معلقة في تعليقات:

```dart
routes: {
  '/splash': (context) => const SplashScreen(),
  // '/login': (context) => const LoginScreen(),   // ← معلّق!
  // '/register': (context) => const RegisterScreen(),
  // '/home': (context) => const HomeScreen(),
},
```

**الحل:** تفعيل الـ routes المطلوبة أو استخدام Navigator مباشرة

---

### 9. 💡 `pubspec.yaml` → لا يستخدم `flutter_secure_storage`

**الملف:** `pubspec.yaml`
**ملاحظة مهمة:** التوثيق في AGENTS.md يقول "Store tokens in `flutter_secure_storage`"
لكن **الكود الفعلي** يستخدم `shared_preferences` عبر `StorageService`.
هذا **غير آمن** لكنه **يعمل** حالياً.

**الحل المستقبلي:** إضافة `flutter_secure_storage` وتشفير الـ token

---

### 10. 💡 طباعة Debug كثيرة في الكود

**الملفات المتأثرة:**
- `auth_service.dart` → كل method فيها `print('🔍...`)` و `print('✅...')`
- `user.dart` → `print('👤 USER MODEL...')`
- `dio_service.dart` → `_LoggingInterceptor` يطبع كل طلب واستجابة

**الحل:** إزالة أو لف العبارات في `kDebugMode`:
```dart
if (kDebugMode) {
  print('🔍 AUTH SERVICE - Response: $responseData');
}
```

---

## 📊 جدول التوافق الحالي (Frontend ↔ Backend)

| الوظيفة | حالة الفرونت | حالة الباك | متوافق؟ |
|---------|-------------|-----------|---------|
| تسجيل الدخول | ✅ يعمل | ✅ يعمل | ✅ نعم |
| تسجيل الخروج | ✅ يعمل | ✅ يعمل | ✅ نعم |
| التسجيل | ❌ يستدعي endpoint مفقود | ❌ غير موجود | ❌ لا |
| جلب المستخدم | ✅ يعمل | ⚠️ يكشف بيانات | ✅ يعمل |
| قائمة التقارير | ✅ يتوقع Array | ✅ يرسل Array | ✅ نعم |
| تفاصيل تقرير | ✅ يتوقع Object | ✅ يرسل Object | ✅ نعم |
| إنشاء تقرير (صورة واحدة) | ✅ يعمل | ✅ يعمل | ✅ نعم |
| إنشاء تقرير (صور متعددة) | ✅ يعمل | ✅ يعمل | ✅ نعم |
| إنشاء تقرير (PDF) | ✅ يعمل | ✅ يعمل | ✅ نعم |
| إنشاء تقرير (فيديو) | ✅ يعمل | ✅ يعمل | ✅ نعم |
| حذف تقرير | ✅ يعمل | ✅ يعمل | ✅ نعم |
| تعديل تقرير | ❌ غير موجود | ❌ غير موجود | ➖ كلاهما مفقود |
| تعديل ملف شخصي | ❌ غير موجود | ❌ غير موجود | ➖ كلاهما مفقود |
| تغيير كلمة مرور | ❌ غير موجود | ❌ غير موجود | ➖ كلاهما مفقود |

---

## ✅ ملخص الإصلاحات حسب الأولوية

### فوري (قبل التسليم):
1. تعطيل `register()` أو إضافة endpoint
2. تصحيح `image_url` fallback في `report.dart`
3. إضافة ثوابت multimedia في `api_constants.dart`

### مهم (قبل الإنتاج):
4. توحيد methods إنشاء التقرير
5. إصلاح singleton pattern عند تغيير URL
6. إزالة debug prints أو لفها في kDebugMode

### تحسينات:
7. تفعيل routes في main.dart
8. التفكير في flutter_secure_storage
9. إضافة pull-to-refresh لقائمة التقارير
