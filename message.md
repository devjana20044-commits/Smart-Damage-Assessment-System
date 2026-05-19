# Response

## تم تنفيذ خطة 05 بالكامل

### التعديلات المنفذة:

#### Backend (Laravel):
1. **Migration جديدة**: `2026_05_16_000001_add_profile_image_to_users_table.php` - إضافة عمود `profile_image` لجدول users
2. **AuthController**: إضافة دالة `updateMe()` لدعم تحديث الاسم، الإيميل، كلمة المرور، ورفع صورة الملف الشخصي
3. **Routes**: تسجيل `Route::match(['put', 'post'], '/me', ...)` لدعم JSON و multipart/form-data

#### Flutter - المشكلة 1 (الملف الشخصي):
- **User model**: إضافة حقل `profileImage` مع `fromJson/toJson/copyWith/==/hashCode`
- **AuthService.updateProfile**: دعم رفع صورة عبر `multipart/form-data` مع `_method: PUT`
- **AuthProvider.updateProfile**: إضافة باراميتر `profileImage`
- **EditProfileScreen**: أيقونة كاميرا لاختيار صورة، معاينة الصورة (محلية أو من URL)، دائرة كبيرة 100px
- **HomeScreen**: صف الـ Drawer بالكامل قابل للضغط، دائرة AppBar تعرض صورة الملف الشخصي عند توفرها

#### Flutter - المشكلة 2 (تحديث التقرير):
- **CreateReportScreen**: تحميل الصور القديمة (`_existingImageUrls`) وعرضها كـ `Image.network` مع زر حذف
- عرض ملف PDF القديم مع زر إزالة
- تمرير `remainingOldImages` عند حفظ التحديث
- إخفاء زر "حفظ كمسودة" في وضع التعديل

#### Flutter - المشكلة 3 (زر حفظ الملف الشخصي):
- الـ Backend الآن يدعم `PUT/POST /me` - الزر سيعمل بشكل صحيح

### المطلوب بعد النشر:
1. `php artisan migrate` على السيرفر
2. `php artisan storage:link` لتفعيل عرض الصور
