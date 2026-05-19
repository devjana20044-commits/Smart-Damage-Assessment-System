# تشخيص مشكلة الأيقونة

## المشكلة الأساسية: `flutter_launcher_icons` لم يتم تشغيله

### الأسباب:

1. **عدم وجود مجلد `mipmap-anydpi-v26`** — هذا المجلد لازم يحتوي على ملفات `ic_launcher.xml` و `ic_launcher_round.xml` الخاصة بالـ Adaptive Icons (لأندرويد 8+). المجلد غير موجود نهائياً، مما يعني أن الأيقونات المخصصة لم يتم توليدها.

2. **عدم وجود `android:roundIcon` في AndroidManifest.xml** — المانيفست ما فيه فقط `android:icon="@mipmap/ic_launcher"` بس ما فيه `android:roundIcon`، وهذا يسبب مشاكل على بعض الأجهزة.

3. **الأيقونات الحالية في mipmap هي الأيقونات الافتراضية لتطبيق Flutter** — مو الأيقونة المخصصة `ico.png`.

### الحل:

#### الخطوة 1: شغّل أمر توليد الأيقونات
```bash
cd smart_damage_assessment
dart run flutter_launcher_icons
```

#### الخطوة 2: إضافة `android:roundIcon` في AndroidManifest.xml
في ملف `android/app/src/main/AndroidManifest.xml`، أضف:
```xml
android:roundIcon="@mipmap/ic_launcher_round"
```

#### الخطوة 3: إعادة بناء التطبيق
```bash
flutter clean
flutter pub get
flutter build apk
```

هل بدك أطبّق الإصلاحات؟
