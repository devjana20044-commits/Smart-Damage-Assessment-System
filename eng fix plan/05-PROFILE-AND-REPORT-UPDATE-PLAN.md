# 05 — خطة تنفيذ شاملة لتعديل الملف الشخصي وتحديث التقرير

> Smart Damage Assessment System — Implementation Plan
> النطاق: Flutter App + Laravel Backend
> الهدف: حل المشاكل الثلاث المتعلقة بـ (1) عرض/تعديل الملف الشخصي، (2) زر تحديث التقرير، (3) زر حفظ التعديلات في صفحة الملف الشخصي.

---

## 0. ملخص تنفيذي (Executive Summary)

| # | المشكلة | السبب الجذري | الأولوية |
|---|---------|--------------|----------|
| 1 | الضغط على الملف الشخصي في الـ Drawer لا يفتح صفحة عرض، فقط زر القلم الصغير يفتح صفحة التعديل، ولا توجد إمكانية لتعديل الصورة. | الصف العلوي في الـ Drawer غير قابل للضغط بالكامل، وصفحة `EditProfileScreen` لا تدعم رفع صورة، والـ `User` model لا يحتوي حقل `profileImage`. | عالية |
| 2 | زر «تحديث التقرير» يظهر أحياناً وكأنه لا يعمل: تفتح الصفحة لكن لا تظهر الصور/PDF/الفيديوهات السابقة وقد لا يتم الحفظ بشكل واضح. | `CreateReportScreen._loadReport()` يحمّل الموقع والوصف فقط ولا يحمّل الصور القديمة ولا يعرضها كمعاينات؛ ولا يرسل `remainingOldImages` عند الحفظ فيُفسَّر ذلك في الـ Backend كحذف للصور. | عالية |
| 3 | زر «حفظ» في صفحة تعديل الملف الشخصي لا يحفظ شيئاً (يبدو معطّلاً أو يفشل صامتاً). | الـ Backend لا يحتوي endpoint بصيغة `PUT /me` (موجود `GET /me` فقط) — لذا الطلب يعود بـ 405 Method Not Allowed، والـ migration لا تحتوي عمود `profile_image` رغم أن `UserResource` يحاول استخدامه. | عالية |

كل هذه المشاكل قابلة للحل دون كسر التوافق مع الميزات الحالية.

---

## 1. الملفات المتأثرة (Files Touched)

### Backend (Laravel)
- `backend/database/migrations/2026_05_16_000001_add_profile_image_to_users_table.php` *(جديد)*
- `backend/app/Models/User.php` *(إضافة `profile_image` إلى `$fillable`)*
- `backend/app/Http/Controllers/AuthController.php` *(إضافة `updateMe`)*
- `backend/routes/api.php` *(تسجيل `PUT /me` و `POST /me` لرفع الصورة)*

### Frontend (Flutter)
- `smart_damage_assessment/lib/models/user.dart`
- `smart_damage_assessment/lib/core/api_constants.dart`
- `smart_damage_assessment/lib/services/auth_service.dart`
- `smart_damage_assessment/lib/providers/auth_provider.dart`
- `smart_damage_assessment/lib/screens/home/home_screen.dart`
- `smart_damage_assessment/lib/screens/auth/edit_profile_screen.dart`
- `smart_damage_assessment/lib/screens/report/create_report_screen.dart`
- `smart_damage_assessment/lib/services/report_service.dart` *(تأكيد `remainingOldImages`)*
- `smart_damage_assessment/lib/core/localization.dart` *(مفاتيح جديدة عند الحاجة)*

---

## 2. المشكلة الأولى: عرض/تعديل الملف الشخصي من الـ Sidebar

### 2.1 المتطلب من المستخدم
> «بدي لما اكبس ع البروفايل يعرضلي ياه مع امكانية اضافة/تعديل الاسم والصورة الموجودين بالسايد بار.»

### 2.2 الوضع الحالي
- في `home_screen.dart` (السطور 636–719): الصف الذي يحوي صورة الحرف الأول + الاسم + الإيميل يفتح المُحرر فقط عبر زر القلم الصغير (السطر 691)، وبقيّة الصف ليست قابلة للضغط.
- لا يوجد حقل `profileImage` في `User` model.
- `EditProfileScreen` تعرض حرفاً واحداً فقط داخل دائرة ولا تسمح بتغيير الصورة.

### 2.3 خطة التنفيذ

**A. تحديث الـ User model** — `lib/models/user.dart`:
- إضافة حقل اختياري `String? profileImage`.
- تحديث `fromJson` و `toJson` و `copyWith` و `==`/`hashCode`.

**B. جعل صف الملف الشخصي في الـ Drawer قابلاً للضغط كاملاً**
- في `home_screen._buildDrawer`: لفّ الصف بأكمله بـ `InkWell`/`GestureDetector` يفتح `EditProfileScreen`.
- إبقاء زر القلم كاختصار بصري لكن السلوك واحد.
- استبدال دائرة الحرف بـ `CircleAvatar` يعرض `user.profileImage` عبر `NetworkImage` إذا كان متوفراً، وإلا يعرض الحرف الأول كما هو الآن.
- تطبيق نفس المنطق على دائرة الـ AppBar (السطور 195–218) لتعرض الصورة.

**C. صفحة `EditProfileScreen` تصبح صفحة عرض + تعديل**
- استبدال الدائرة الحالية بـ `CircleAvatar` كبير (شعاع 50) داخل `Stack` مع زر كاميرا صغير في الأسفل-اليمين (لتغيير الصورة).
- إضافة `File? _newProfileImage` كحالة، وإضافة دالة `_pickProfileImage()` تستخدم `image_picker` (مستخدم أصلاً في المشروع) مع خيارين: من الكاميرا أو من المعرض.
- عرض المعاينة من الـ `File` المحلي إن وُجد، وإلا من `user.profileImage` (URL)، وإلا حرف الاسم الأول.
- عند الحفظ، تمرير `_newProfileImage` إلى `AuthProvider.updateProfile()`.

**D. تحديث `AuthProvider` و `AuthService`**
- توقيع `updateProfile` يصبح:
  ```dart
  Future<bool> updateProfile({
    required String name,
    required String email,
    String? currentPassword,
    String? newPassword,
    String? newPasswordConfirmation,
    File? profileImage,
  });
  ```
- في `AuthService.updateProfile`: إذا كان `profileImage != null` نرسل الطلب كـ `multipart/form-data` مع `_method: PUT` (نفس أسلوب `ReportService.updateReport`)، وإلا نبقى على JSON `PUT`.

---

## 3. المشكلة الثانية: زر «تحديث التقرير»

### 3.1 المتطلب من المستخدم
> «لما اكبس ع زر تحديث التقرير ما عم يصير. بدي اكبس ع الزر بعديني بيصير عندي التعديل ع أي شي بمعلومات التقرير وبعدين خيار حفظ التعديلات مفعل ليحفظ كل شي عدلته (مثل صفحة إنشاء تقرير).»

### 3.2 الوضع الحالي
- `report_details_screen.dart` السطر 813 يستدعي `_startEditing(report)` الذي ينتقل إلى `CreateReportScreen(reportId: report.id)`.
- `CreateReportScreen._loadReport()` السطور 64–90 تحمّل فقط:
  - `_locationController.text` ← `report.location.raw`
  - `_notesController.text` ← `report.description.raw`
  - `_currentPosition` ← coordinates
  - `_videoLinks`
- **لا تُحمَّل الصور القديمة** (لأنها URLs لا `File`).
- **لا يُحمَّل ملف PDF القديم**.
- لا يوجد عرض لمعاينات الصور الموجودة على الـ Backend.
- عند الحفظ، `images` المرسلة فارغة فيؤدي ذلك إلى إرسال الفورم بدون أي مرجع للصور القديمة، والـ backend (حسب نمط `remainingOldImages`) قد يفسّر ذلك كحذف.

### 3.3 خطة التنفيذ

**A. توسيع حالة `_CreateReportScreenState`**:
- إضافة `List<String> _existingImageUrls = [];` و `List<String> _removedExistingImageUrls = [];`
- إضافة `String? _existingPdfUrl;`

**B. تحديث `_loadReport()`**:
- بعد جلب `report`، أضف:
  ```dart
  _existingImageUrls = List<String>.from(report.images);
  _existingPdfUrl = report.pdfUrl; // إن وُجد الحقل
  ```

**C. تحديث `_buildMediaSection`**:
- إذا كانت `_existingImageUrls.isNotEmpty`، اعرض `PageView` للصور القديمة باستخدام `Image.network`، مع زر `x` لإزالة كل واحدة (يحركها من `_existingImageUrls` إلى `_removedExistingImageUrls`).
- ابقِ مكدّس الصور الجديدة (`_selectedImages`) كما هو لكن بعد الصور القديمة.
- العداد يصبح: `${_existingImageUrls.length + _selectedImages.length} صور`.

**D. تحديث `_buildPdfSection`**:
- إذا كان `_existingPdfUrl != null` و `_selectedPdf == null`، اعرض اسم ملف الـ PDF القديم مع زر `x` لإزالته (يضع علماً منطقياً أو يفرغ `_existingPdfUrl`).

**E. تحديث `_submitReport()` في وضع التعديل (`widget.reportId != null`)**:
- استدعِ `reportProvider.updateReport(...)` مع تمرير:
  - `remainingOldImages: _existingImageUrls` (الصور التي بقيت بعد الإزالات)
  - `images: _selectedImages` (الجديدة)
  - باقي الحقول كما هي.

**F. تحديث `ReportService.updateReport`**:
- الموجود حالياً (السطور 152–156) يدعم `remainingOldImages[i]`. تأكيد أن الـ key يطابق ما يقرأه الـ Backend. إذا كان الـ Backend يتوقع `remaining_old_images[]` فعدّل المفتاح إلى:
  ```dart
  formDataMap['remaining_old_images[$i]'] = remainingOldImages[i];
  ```
  وهذا ما هو موجود بالفعل ✅.

**G. التأكد من زر الحفظ ظاهر ومفعّل في وضع التعديل**:
- في الـ Footer (السطور 1004–1105): الزر الأول يستخدم `loc.updateReport` عند `reportId != null` ✅. تأكد أن:
  - النص = «تحديث التقرير» / «Update Report».
  - `onPressed = reportProvider.isLoading ? null : _submitReport` ✅.
  - لا يوجد شرط آخر يعطّل الزر.
- إخفاء زر «حفظ كمسودة» في وضع التعديل (لا معنى لها على تقرير منشور).

**H. عند نجاح التحديث**:
- إظهار `SnackBar` بالنجاح (موجود السطر 327) ثم `Navigator.pop()` ✅.
- في `report_details_screen._startEditing` (السطر 108–112) إعادة جلب التقرير عبر `fetchReportById` ✅.

---

## 4. المشكلة الثالثة: زر «حفظ» في صفحة تعديل الملف الشخصي

### 4.1 المتطلب من المستخدم
> «فعّل زر حفظ ليحفظ التعديل بصفحة تعديل الملف الشخصي بالتطبيق.»

### 4.2 الوضع الحالي
- الزر في `edit_profile_screen.dart` السطور 267–296 موصول إلى `_save()` ويستدعي `AuthProvider.updateProfile()` ← `AuthService.updateProfile()` ← `dio.put(/me, ...)`.
- **المشكلة الحقيقية: لا يوجد `PUT /me` في الـ Backend.** الموجود فقط:
  ```php
  Route::get('/me', [AuthController::class, 'me']);
  ```
- لذا الطلب يفشل بـ 405 ويظهر للمستخدم كأن الزر لا يعمل.
- أيضاً `UserResource` يحاول الوصول إلى `profile_image` لكن الحقل غير موجود في الجدول (سيُعيد `null` صامتاً).

### 4.3 خطة التنفيذ

**A. Migration جديدة** — `backend/database/migrations/2026_05_16_000001_add_profile_image_to_users_table.php`:
```php
public function up(): void
{
    Schema::table('users', function (Blueprint $table) {
        $table->string('profile_image')->nullable()->after('role');
    });
}

public function down(): void
{
    Schema::table('users', function (Blueprint $table) {
        $table->dropColumn('profile_image');
    });
}
```

**B. تحديث `User` model** — `backend/app/Models/User.php`:
- إضافة `'profile_image'` إلى `$fillable`.

**C. إضافة `updateMe` في `AuthController`**:
```php
public function updateMe(Request $request): JsonResponse
{
    $user = $request->user();

    $validated = $request->validate([
        'name' => 'sometimes|required|string|max:255',
        'email' => 'sometimes|required|email|unique:users,email,' . $user->id,
        'current_password' => 'sometimes|required_with:password|string',
        'password' => 'sometimes|required|string|min:8|confirmed',
        'profile_image' => 'sometimes|file|image|max:5120', // 5MB
    ]);

    if (isset($validated['password'])) {
        if (! \Hash::check($request->current_password, $user->password)) {
            return response()->json(['error' => 'Current password is incorrect'], 422);
        }
        $user->password = \Hash::make($validated['password']);
    }

    if ($request->hasFile('profile_image')) {
        if ($user->profile_image) {
            \Storage::disk('public')->delete($user->profile_image);
        }
        $user->profile_image = $request->file('profile_image')->store('avatars', 'public');
    }

    foreach (['name', 'email'] as $field) {
        if (isset($validated[$field])) {
            $user->$field = $validated[$field];
        }
    }

    $user->save();

    return response()->json([
        'user' => UserResource::make($user)->resolve(),
    ]);
}
```

**D. تسجيل الـ Routes** — `backend/routes/api.php`:
```php
Route::middleware('auth:sanctum')->group(function () {
    // ... existing
    Route::match(['put', 'post'], '/me', [AuthController::class, 'updateMe']);
});
```
> ملاحظة: نقبل `POST` أيضاً ليتمكن الـ Flutter من استخدام `_method: PUT` مع `multipart/form-data` (نفس نمط `updateReport`).

**E. تحديث الـ Frontend (Flutter)**
- `AuthService.updateProfile`: إذا وُجد `profileImage`، نبني `FormData` ونرسلها بـ `dio.post('/me', data: formData)` مع `_method: PUT`. إذا لا، نرسل JSON بـ `dio.put('/me', ...)` كما هو.
- بعد النجاح، الـ Backend يرجع `{ user: {...} }` فيتم تحديث `User` في `StorageService` وفي `AuthProvider`.

**F. تأكيد دورة الأخطاء**
- في `_save()` الحالية، إذا فشل التحديث يُعرض `errorMessage` من الـ provider. مع وجود endpoint صحيح الآن، سيكون الـ feedback صحيحاً.

---

## 5. الترتيب الزمني للتنفيذ (Execution Order)

1. **Backend أولاً** (لا يعمل الـ frontend بدونه):
   1. إنشاء الـ migration وتشغيل `php artisan migrate`.
   2. إضافة `profile_image` إلى `$fillable`.
   3. إضافة `updateMe` في الـ Controller.
   4. تسجيل الـ Route.
   5. التأكد من `php artisan storage:link` لتعمل الصور.
2. **Flutter Model & Service Layer**:
   1. تحديث `User.fromJson/toJson/copyWith` لإضافة `profileImage`.
   2. تحديث `AuthService.updateProfile` لدعم رفع الصورة.
   3. تحديث `AuthProvider.updateProfile` بنفس التوقيع.
3. **Flutter UI**:
   1. تحديث `EditProfileScreen` (اختيار صورة + عرض).
   2. تحديث الـ Drawer ودائرة الـ AppBar في `HomeScreen` (عرض الصورة + الضغط على الصف كاملاً).
4. **Flutter — تحديث التقرير**:
   1. توسيع حالة `CreateReportScreen` لتحميل الصور القديمة وعرضها.
   2. تمرير `remainingOldImages` عند الحفظ.
   3. إخفاء زر «حفظ كمسودة» في وضع التعديل.
5. **اختبار يدوي شامل** (انظر القسم 6).
6. **Commit & Push**.

---

## 6. خطة الاختبار اليدوي (QA Checklist)

### 6.1 الملف الشخصي
- [ ] افتح الـ Drawer → اضغط على صف الملف الشخصي بأي مكان (ليس فقط القلم) → يجب أن تفتح صفحة التعديل.
- [ ] في صفحة التعديل: اضغط أيقونة الكاميرا → اختر صورة → تظهر المعاينة.
- [ ] اضغط «حفظ» → SnackBar نجاح → عودة للشاشة السابقة.
- [ ] افتح الـ Drawer مجدداً → الصورة الجديدة تظهر بدلاً من حرف الاسم.
- [ ] صورة دائرة الـ AppBar محدّثة.
- [ ] أعد تشغيل التطبيق (logout/login غير لازمة) → الصورة لا تزال تظهر.
- [ ] غيّر الاسم وحده دون اختيار صورة → يُحفظ بنجاح.
- [ ] غيّر كلمة المرور مع كلمة المرور الحالية الصحيحة → نجاح.
- [ ] غيّر كلمة المرور بكلمة حالية خاطئة → رسالة خطأ واضحة.

### 6.2 تحديث التقرير
- [ ] افتح تقريراً موجوداً → اضغط «تحديث التقرير» → تفتح صفحة CreateReport بصيغة «تحديث التقرير».
- [ ] حقل الموقع معبأ مسبقاً بقيمة التقرير ✅.
- [ ] حقل الملاحظات معبأ ✅.
- [ ] الإحداثيات معروضة على بطاقة الخريطة ✅.
- [ ] الصور القديمة تظهر كمعاينات قابلة للحذف.
- [ ] PDF القديم (إن وجد) يظهر باسمه مع زر حذف.
- [ ] روابط الفيديو القديمة معروضة في القائمة.
- [ ] أزل صورة قديمة + أضف صورة جديدة → احفظ → التقرير يُحدَّث على الـ Backend بنفس النتيجة المرئية.
- [ ] أزل كل الصور القديمة دون إضافة جديدة → تحقق أن الـ Backend لا يرفض الطلب (أو يُرفض برسالة واضحة إن كانت الصور مطلوبة).
- [ ] غيّر الموقع فقط وأرسل → النص يُحفظ، الصور تبقى.

### 6.3 الإيميل والتحقق من الـ Backend
- [ ] `PUT /me` بدون auth token → 401.
- [ ] `PUT /me` مع `name` صالح → 200 + `user` محدّث.
- [ ] `POST /me` (multipart مع `_method: PUT` + `profile_image`) → 200 + URL صحيح في `profile_image`.
- [ ] `PUT /me` مع `email` مأخوذ من مستخدم آخر → 422 unique violation.

---

## 7. الـ Risks وكيفية تقليلها

| Risk | Mitigation |
|------|-----------|
| نسيان `php artisan storage:link` على بيئة الإنتاج → الصور لا تظهر. | إضافة الأمر إلى deployment script وتوثيقه في `README`. |
| المستخدمون القدامى ليس لديهم `profile_image` → الـ frontend يجب أن يتعامل مع `null` بسلاسة. | UI fallback إلى حرف الاسم الأول (موجود فعلاً). |
| إزالة كل الصور من تقرير قديم قد يخرق منطق الـ Backend الحالي. | اختبار سيناريو الصورة الواحدة المتبقية + رسالة validation عند صفر صور. |
| رفع صورة كبيرة جداً → خطأ 413. | حد `max:5120` على الـ Backend + ضغط `imageQuality: 80` على الـ Flutter. |

---

## 8. ما هو خارج النطاق (Out of Scope)

- لا توجد تغييرات على نظام الـ Authentication الأساسي (Sanctum tokens تبقى كما هي).
- لا تعديل على شاشة الإحصائيات، الإعدادات، أو المسودات.
- لا تغييرات على لون/Theme المشروع.
- مشاركة التقرير عبر السوشال غير مشمولة.

---

## 9. ملاحظات للمراجعة (Reviewer Notes)

- يستخدم المشروع نمط Provider — جميع التغييرات تتبع نفس النمط.
- استُخدم `image_picker` و `permission_handler` المستخدمة بالفعل في `create_report_screen.dart` (لا حاجة لحزم جديدة).
- استُخدمت نفس آلية `_method: PUT` مع `multipart/form-data` المعتمدة في `ReportService.updateReport` لضمان التماسك المعماري.
- جميع نصوص الواجهة الجديدة يجب أن تضاف للـ `core/localization.dart` بكلتا اللغتين (en, ar).

— انتهى —
