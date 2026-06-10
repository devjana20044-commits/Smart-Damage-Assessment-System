# 🧠 Agent.md - Smart Damage Assessment System

## 📊 نظرة عامة
- **نوع المشروع:** Full-stack damage assessment system (Flutter mobile app + Laravel backend)
- **اللغة:** Dart (Flutter), PHP (Laravel)
- **الإطار:** Flutter 3.x, Laravel 11.x
- **نقطة الدخول:** 
  - Backend: `backend/routes/api.php`
  - Flutter: `smart_damage_assessment/lib/main.dart`

## 🌲 المخطط الشجري
smart-damage-assessment-system/
├── backend/                            # Laravel backend app
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/
│   │   │   │   └── Api/                # API Controllers (AuthController, ReportController)
│   │   │   ├── Requests/               # Validation requests (StoreReportRequest, ProfileUpdateRequest)
│   │   │   └── Resources/              # API resources (ReportResource)
│   │   └── Models/                     # Database models (User, Report)
│   ├── routes/
│   │   └── api.php                     # API route definitions
│   └── ...
├── smart_damage_assessment/            # Flutter mobile app
│   ├── lib/
│   │   ├── core/                       # API constants, config (api_constants.dart)
│   │   ├── models/                     # Data models (user.dart, report.dart)
│   │   ├── services/                   # API services (auth_service.dart, report_service.dart)
│   │   └── ...
│   └── pubspec.yaml                    # Flutter dependencies

## 🛠️ أوامر التشغيل
### Backend
| الأمر | الوظيفة |
|-------|---------|
| `php artisan serve --host=0.0.0.0 --port=8000` | تشغيل خادم التطوير |
| `php artisan migrate` | تشغيل الهجرات |
| `php artisan test` | تشغيل الاختبارات |

### Frontend (Flutter)
| الأمر | الوظيفة |
|-------|---------|
| `flutter pub get` | تحميل الحزم |
| `flutter run` | تشغيل التطبيق |

## 📦 التبعيات الرئيسية
- **Backend:** Laravel Sanctum, Gemini API Integration.
- **Frontend:** Dio (HTTP Client), Provider (State Management), SharedPreferences (Storage).

## ✅ أفضل الممارسات المكتشفة
- استخدام `MultipartFile.fromFile` لرفع الملفات مع Dio.
- استخدام `_method: PUT` عند إرسال طلبات تعديل البيانات (multipart/form-data) مع Laravel.
- إرسال الصور والملفات عبر `public` storage وجعل الروابط كاملة باستخدام `url('storage/...')`.

## ⚠️ المشاكل المعروفة والحلول
- تعيين `Content-Type` يدوياً لـ `multipart/form-data` في Dio يحذف boundary التلقائي ويسبب فشل خادم الـ backend في قراءة البيانات.
- نقص الـ endpoints مثل `/register` وتعديل الملف الشخصي `/me` وتحديث التقارير `/reports/{id}` في Laravel.
- فشل التحديث للتقارير عند عدم وجود ملفات جديدة بسبب مشاكل الـ Multipart الفارغ والـ Spoofing: تم الحل بفصل طلبات الـ JSON والـ Multipart.
- عدم التحقق من كلمة المرور الحالية في تعديل الملف الشخصي: تم الحل بفرض `current_password` في الـ Request والتحقق عبر `Hash::check`.

## 🚫 أنماط يجب تجنبها
- تعيين `Content-Type` يدوياً لـ `multipart/form-data` في Flutter (دع Dio يتعامل معها تلقائياً).
- إرسال طلبات `POST` مع Spoofing كـ `multipart/form-data` بدون ملفات: يسبب مشاكل معالجة على السيرفرات، بدلاً من ذلك استخدم طلبات `PUT` JSON نظيفة.

## 🧹 صيانة الذاكرة (Memory Hygiene)
### آخر تنظيف: 2026-06-10
- المخطط الشجري محدث.
- المشاكل المعروفة محدثة.
