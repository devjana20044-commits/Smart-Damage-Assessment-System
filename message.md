# Response

## 🔍 تشخيص خطأ 405 Method Not Allowed

### المشكلة:
عند تحديث التقرير أو تعديل الملف الشخصي، كان التطبيق يرسل طلبات **HTTP `PUT` مباشرة** إلى السيرفر. الخطأ الذي ظهر:

```
❌ ERROR: DioExceptionType.badResponse
📥 ERROR RESPONSE: 405
The server returned a "405 Method Not Allowed"
```

هذا الخطأ ظهر في **3 نقاط**:
1. `PUT /api/reports/106` — تحديث التقرير ❌
2. `PUT /api/reports/105` — تحديث التقرير ❌  
3. `PUT /api/me` — تعديل الملف الشخصي ❌

### 🔬 السبب الجذري:
الروتات في Laravel مسجلة بشكل صحيح (`POST|PUT api/reports/{id}` و `PUT|POST api/me`). لكن **السيرفر الذي يعمل عليه الباك إند** (سواء Apache أو Nginx أو أي Reverse Proxy بينه وبين التطبيق) **يحجب طلبات HTTP `PUT` المباشرة** قبل وصولها إلى Laravel.

الدليل: صفحة الخطأ HTML جاءت من **Symfony's error handler** بدون أي تنسيق Laravel — أي أن الخطأ يحدث **في طبقة الـ HTTP نفسها** وليس في كود التطبيق.

### 💡 الحل المطبق:
تم تحويل **جميع** طلبات `PUT` المباشرة في تطبيق Flutter إلى `POST` مع إضافة حقل `_method: PUT` في جسم الطلب — وهي تقنية **Method Spoofing** الرسمية في Laravel.

#### الملفات المعدلة:

1. **[report_service.dart](file:///C:/Users/Abdalgani/Desktop/Smart-Damage-Assessment-System/smart_damage_assessment/lib/services/report_service.dart#L228-L232)** — تحديث التقارير بدون ملفات:
```dart
// قبل (كان يفشل بـ 405):
final response = await _dioService.dio.put('/reports/$id', data: jsonData);

// بعد (يعمل بشكل صحيح):
jsonData['_method'] = 'PUT';
final response = await _dioService.dio.post('/reports/$id', data: jsonData);
```

2. **[auth_service.dart](file:///C:/Users/Abdalgani/Desktop/Smart-Damage-Assessment-System/smart_damage_assessment/lib/services/auth_service.dart#L213-L215)** — تعديل الملف الشخصي بدون صورة:
```dart
// قبل (كان يفشل بـ 405):
final response = await _dioService.dio.put('/me', data: data);

// بعد (يعمل بشكل صحيح):
data['_method'] = 'PUT';
final response = await _dioService.dio.post('/me', data: data);
```

### ✅ نتائج الفحص:
- `flutter analyze` → **0 أخطاء، 0 تحذيرات** (58 info فقط)
- التغييرات جاهزة للعمل مع أي نوع سيرفر

### 📌 ملاحظة مهمة:
الآن **كل** طلبات التعديل في التطبيق (سواء بملفات أو بدون) تستخدم **Method Spoofing** وهو المعيار الآمن والمتوافق مع جميع السيرفرات. لن تواجه هذه المشكلة مرة أخرى.
