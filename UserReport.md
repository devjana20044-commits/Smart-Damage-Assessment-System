# 📋 UserReport - Smart Damage Assessment System

## 🏗️ نظرة عامة
نظام متكامل لتقييم الأضرار باستخدام الذكاء الاصطناعي، يربط بين تطبيق هاتف ذكي (Flutter) ولوحة تحكم خلفية (Laravel).

## 📝 سجل التغييرات
| التاريخ | التغيير | الملفات المتأثرة |
|---------|---------|------------------|
| 2026-05-19 | تهيئة مستند التغييرات وذاكرة العميل | Agent.md, UserReport.md |
| 2026-05-19 | حل مشاكل التوافق بالكامل وتطوير الـ API والـ Client | AuthController.php, ReportController.php, ProfileUpdateRequest.php, UpdateReportRequest.php, api.php, auth_service.dart, report_service.dart, TestCase.php, phpunit.xml, UserFactory.php |
| 2026-06-10 | حل مشكلة زر التحديث في التقارير وتغيير كلمة السر في الحساب الشخصي | ProfileUpdateRequest.php, AuthController.php, ApiCompatibilityTest.php, report_service.dart, edit_profile_screen.dart |

## 🐛 المشاكل والحلول
| المشكلة | الحالة | الحل |
|---------|--------|------|
| عدم عمل زر التحديث في صفحة إنشاء التقرير | تم الحل | تم تمييز طلبات التحديث التي لا تحتوي على ملفات جديدة وإرسالها كـ `PUT` JSON نظيف لتجنب مشاكل الـ Multipart الفارغ والـ Spoofing، مع إرسال مصفوفات فارغة لضمان معالجة الحذف في السيرفر. |
| عدم القدرة على تغيير كلمة المرور في الحساب الشخصي | تم الحل | تم إضافة التحقق من كلمة المرور الحالية في الـ backend كشرط أمني ومنطقي لتغيير كلمة المرور، وإضافته كـ validator في Flutter لتجنيب إرسال طلبات خاطئة. |
| عدم وجود `current_password` في `ProfileUpdateRequest` | تم الحل | تم إضافته كحقل اختياري ولكن إلزامي إذا تم كتابة كلمة مرور جديدة في الطلب. |
| عدم وجود `updateMe` في `AuthController` | تم الحل | كتابة الـ method ودعم تحديث الاسم والبريد وكلمة المرور وصورة الحساب الشخصي مع مسح الصورة القديمة من القرص. |
| فشل تحديث التقارير لعدم وجود `update` في `ReportController` | تم الحل | إنشاء طلب تحقق `UpdateReportRequest` وكتابة الـ method ودعم رفع صور متعددة جديدة مع الاحتفاظ بالصور القديمة وحذف غير المرغوب فيها، وإعادة تشغيل معالجة الذكاء الاصطناعي. |
| تعارض ترويسة `Content-Type` في Flutter | تم الحل | إزالة التحديد اليدوي لـ `multipart/form-data` في طلبات Dio لكي يقوم Dio بإنشاء الحد الفاصل (Boundary) للبيانات المرفوعة بشكل تلقائي وصحيح. |

## 💻 أخطاء التيرمينال
| الأمر | الخطأ | الحل |
|-------|-------|------|
| `php artisan test` | `Could not read XML from file ... phpunit.xml.dist` | تم إنشاء ملف `phpunit.xml` مخصص للاختبارات وملف `tests/TestCase.php` المفقود. |
| `php artisan test` | `Class "Database\Factories\UserFactory" not found` | تم إنشاء ملف `database/factories/UserFactory.php` لدعم بناء كائنات المستخدم في بيئة الاختبار. |
| `php artisan test` | `Call to undefined method QueueFake::assertDispatched()` | تم تعديل استدعاء التحقق إلى `Queue::assertPushed()` المتوافق مع مكتبة فحص الطوابير في Laravel. |
