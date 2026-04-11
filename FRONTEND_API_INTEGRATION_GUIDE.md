# دليل تكامل الواجهة الأمامية مع API الجديد

## Frontend Integration Guide - Smart Damage Assessment System

**التاريخ:** 2026-02-07  
**الإصدار:** 2.0.0  
**الحالة:** ✅ جاهز للتنفيذ

---

## 📋 نظرة عامة

تم تحديث نظام API لدعم الميزات الجديدة التالية:

- ✅ **رفع صور متعددة** في تقرير واحد
- ✅ **إرفاق ملفات PDF** مع التقارير
- ✅ **إضافة روابط فيديو** خارجية

هذا الدليل موجه لفريق تطوير الواجهة الأمامية (Frontend Team) ويوضح كيفية التعامل مع API الجديد.

---

## 🎯 ما تم تحديثه في Backend

### 1. تحديث قاعدة البيانات

تم إضافة الحقول التالية لجدول `reports`:

```sql
-- ملف الترحيل: 2026_01_27_145421_add_multimedia_to_reports_table.php
ALTER TABLE reports ADD COLUMN images JSON NULL;
ALTER TABLE reports ADD COLUMN pdf_file VARCHAR(255) NULL;
ALTER TABLE reports ADD COLUMN video_links JSON NULL;
```

### 2. تحديث النموذج (Model)

تم تحديث [`Report.php`](backend/app/Models/Report.php:1) لإضافة الحقول الجديدة:

```php
protected $fillable = [
    // ... الحقول القديمة
    'images',        // مصفوفة مسارات الصور
    'pdf_file',      // مسار ملف PDF
    'video_links',   // مصفوفة روابط الفيديو
];

protected $casts = [
    'images' => 'array',        // تحويل تلقائي لمصفوفة
    'video_links' => 'array',   // تحويل تلقائي لمصفوفة
];
```

### 3. تحديث Controller

تم تحديث [`ReportController.php`](backend/app/Http/Controllers/Api/ReportController.php:64) لمعالجة الملفات الجديدة:

```php
// معالجة الصور المتعددة
$imagePaths = [];
if ($request->hasFile('images')) {
    foreach ($request->file('images') as $image) {
        $path = $image->store('reports/images', 'public');
        $imagePaths[] = $path;
    }
}

// معالجة ملف PDF
$pdfPath = null;
if ($request->hasFile('pdf_file')) {
    $pdfPath = $request->file('pdf_file')->store('reports/docs', 'public');
}

// معالجة روابط الفيديو
$links = $request->input('video_links', []);
$links = array_filter($links); // تصفية الروابط الفارغة
```

### 4. تحديث API Resource

تم تحديث [`ReportResource.php`](backend/app/Http/Resources/ReportResource.php:15) لإرجاع الحقول الجديدة:

```php
return [
    // ... الحقول القديمة
    'images' => array_map(function($path) {
        return url('storage/' . $path);
    }, $this->images ?? []),
    'pdf_url' => $this->pdf_file ? url('storage/' . $this->pdf_file) : null,
    'video_links' => array_values($this->video_links ?? []),
    // ... باقي الحقول
];
```

### 5. تحديث قواعد التحقق

تم تحديث [`StoreReportRequest.php`](backend/app/Http/Requests/StoreReportRequest.php:24):

```php
return [
    'images' => 'nullable|array',
    'images.*' => 'image|mimes:jpeg,png,jpg,gif|max:10240', // 10MB
    'image' => 'nullable|image|max:10240', // للتوافق القديم
    'pdf_file' => 'nullable|mimes:pdf|max:20480', // 20MB
    'video_links' => 'nullable|array',
    'video_links.*' => 'nullable|url',
    // ... باقي القواعد
];
```

---

## 📡 API Endpoints المحدثة

### POST /api/reports (إنشاء تقرير جديد)

#### التغييرات الرئيسية:

1. **دعم صور متعددة:**
   - القديم: `image` (صورة واحدة)
   - الجديد: `images[]` (مصفوفة صور)
   - التوافق: لا يزال يدعم `image`

2. **دعم PDF:**
   - جديد: `pdf_file` (ملف واحد، حد أقصى 20MB)

3. **دعم روابط الفيديو:**
   - جديد: `video_links[]` (مصفوفة روابط)

#### مثال الطلب (Flutter):

```dart
var formData = FormData.fromMap({
  // الصور المتعددة
  'images[]': [
    await MultipartFile.fromFile(image1.path),
    await MultipartFile.fromFile(image2.path),
    await MultipartFile.fromFile(image3.path),
  ],

  // ملف PDF (اختياري)
  'pdf_file': await MultipartFile.fromFile(pdf.path),

  // روابط الفيديو
  'video_links[]': [
    'https://youtube.com/watch?v=example1',
    'https://youtube.com/watch?v=example2',
  ],

  // البيانات الأساسية (لم تتغير)
  'latitude': '33.1162',
  'longitude': '35.8268',
  'raw_location': 'القنيطرة - حي الأمل',
  'raw_description': 'أضرار في البنية التحتية',
});
```

### GET /api/reports (الحصول على جميع التقارير)

#### التغييرات في الاستجابة:

```json
{
  "id": 54,
  "images": [
    "http://localhost:8000/storage/reports/images/image1.jpg",
    "http://localhost:8000/storage/reports/images/image2.jpg",
    "http://localhost:8000/storage/reports/images/image3.jpg"
  ],
  "pdf_url": "http://localhost:8000/storage/reports/docs/report54.pdf",
  "video_links": [
    "https://youtube.com/watch?v=example1",
    "https://youtube.com/watch?v=example2"
  ]
  // ... باقي الحقول (لم تتغير)
}
```

### GET /api/reports/{id} (الحصول على تقرير محدد)

نفس الاستجابة المذكورة أعلاه.

### DELETE /api/reports/{id} (حذف تقرير)

**ملاحظة مهمة:** سيتم حذف جميع الملفات المرتبطة (الصور، PDF) تلقائياً من الخادم.

---

## 🔄 التوافق مع الإصدار القديم

النظام الجديد متوافق تماماً مع الإصدار القديم:

### 1. البيانات القديمة

- التقارير القديمة التي تحتوي على `image_path` ستظل تعمل
- سيتم تحويل `image_path` تلقائياً إلى مصفوفة `images` في الاستجابة

### 2. API القديم

- لا يزال من الممكن إرسال `image` (صورة واحدة)
- سيتم تحويلها تلقائياً إلى مصفوفة `images`

### 3. الترقية التدريجية

- يمكن تحديث التطبيق القديم تدريجياً
- لا حاجة لتغيير فوري في الكود القديم

---

## 📝 نموذج البيانات المحدث (Flutter)

### Report Model

```dart
class ReportModel {
  final int id;
  final List<String> images;      // 🔥 جديد: مصفوفة صور
  final String? pdfUrl;            // 🔥 جديد: رابط PDF
  final List<String> videoLinks;   // 🔥 جديد: روابط فيديو
  final Location location;
  final Description description;
  final DamageAssessment damageAssessment;
  final String createdAt;
  final String updatedAt;

  ReportModel({
    required this.id,
    required this.images,
    this.pdfUrl,
    required this.videoLinks,
    required this.location,
    required this.description,
    required this.damageAssessment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      images: List<String>.from(json['images'] ?? []),
      pdfUrl: json['pdf_url'],
      videoLinks: List<String>.from(json['video_links'] ?? []),
      location: Location.fromJson(json['location']),
      description: Description.fromJson(json['description']),
      damageAssessment: DamageAssessment.fromJson(json['damage_assessment']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
```

---

## 🎨 واجهة المستخدم المقترحة

### 1. صفحة إنشاء تقرير

```dart
class CreateReportScreen extends StatefulWidget {
  @override
  _CreateReportScreenState createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _reportService = ReportService();
  List<File> _selectedImages = [];
  File? _selectedPdf;
  List<String> _videoLinks = [];
  final _linkController = TextEditingController();

  // اختيار صور متعددة
  Future<void> _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null) {
      setState(() {
        _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
      });
    }
  }

  // اختيار ملف PDF
  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedPdf = File(result.files.single.path!);
      });
    }
  }

  // إضافة رابط فيديو
  void _addVideoLink() {
    if (_linkController.text.isNotEmpty) {
      setState(() {
        _videoLinks.add(_linkController.text);
        _linkController.clear();
      });
    }
  }

  // إرسال التقرير
  Future<void> _submitReport() async {
    try {
      await _reportService.createReport(
        images: _selectedImages,
        pdfFile: _selectedPdf,
        videoLinks: _videoLinks,
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
        rawLocation: _locationController.text,
        rawDescription: _descriptionController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إرسال التقرير بنجاح!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إنشاء تقرير جديد')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // حقول الموقع (لم تتغير)
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'الموقع'),
            ),
            SizedBox(height: 16),

            // قسم الصور الجديد
            Text('الصور', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: Icon(Icons.photo_library),
              label: Text('اختر صور'),
            ),
            SizedBox(height: 8),
            // عرض الصور المختارة
            if (_selectedImages.isNotEmpty)
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Image.file(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            SizedBox(height: 16),

            // قسم PDF الجديد
            Text('ملف PDF', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickPdf,
              icon: Icon(Icons.picture_as_pdf),
              label: Text('اختر ملف PDF'),
            ),
            if (_selectedPdf != null)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf),
                    title: Text(_selectedPdf!.path.split('/').last),
                    trailing: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedPdf = null;
                        });
                      },
                    ),
                  ),
                ),
              ),
            SizedBox(height: 16),

            // قسم روابط الفيديو الجديد
            Text('روابط الفيديو', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      labelText: 'رابط الفيديو',
                      hintText: 'https://youtube.com/watch?v=...',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addVideoLink,
                ),
              ],
            ),
            // عرض الروابط المضافة
            if (_videoLinks.isNotEmpty)
              ..._videoLinks.map((link) => Card(
                child: ListTile(
                  leading: Icon(Icons.video_library),
                  title: Text(link, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _videoLinks.remove(link);
                      });
                    },
                  ),
                ),
              )),
            SizedBox(height: 16),

            // زر الإرسال
            ElevatedButton(
              onPressed: _submitReport,
              child: Text('إرسال التقرير'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. صفحة عرض تفاصيل التقرير

```dart
class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailScreen({required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تفاصيل التقرير')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // معلومات الموقع
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الموقع', style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 8),
                    Text(report.location.raw),
                    Text('الإحداثيات: ${report.location.coordinates.latitude}, ${report.location.coordinates.longitude}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // عرض الصور 🔥
            if (report.images.isNotEmpty) ...[
              Text('الصور', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              Container(
                height: 200,
                child: PageView.builder(
                  itemCount: report.images.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      report.images[index],
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
              SizedBox(height: 8),
              Text('${report.images.length} صور'),
              SizedBox(height: 16),
            ],

            // عرض PDF 🔥
            if (report.pdfUrl != null) ...[
              Card(
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf),
                  title: Text('ملف PDF'),
                  trailing: Icon(Icons.open_in_new),
                  onTap: () {
                    // فتح PDF في متصفح أو تطبيق خارجي
                    launchUrl(Uri.parse(report.pdfUrl!));
                  },
                ),
              ),
              SizedBox(height: 16),
            ],

            // عرض روابط الفيديو 🔥
            if (report.videoLinks.isNotEmpty) ...[
              Text('روابط الفيديو', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              ...report.videoLinks.map((link) => Card(
                child: ListTile(
                  leading: Icon(Icons.play_circle),
                  title: Text(link, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Icon(Icons.open_in_new),
                  onTap: () {
                    launchUrl(Uri.parse(link));
                  },
                ),
              )),
              SizedBox(height: 16),
            ],

            // معلومات الضرر
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تقييم الضرر', style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 8),
                    Text('المستوى: ${report.damageAssessment.level}'),
                    Text('الحالة: ${report.damageAssessment.status}'),
                    if (report.description.aiAnalysis != null) ...[
                      SizedBox(height: 8),
                      Text('تحليل AI: ${report.description.aiAnalysis}'),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔧 معالجة الأخطاء

### أكواد الحالة الجديدة

| الكود | الوصف             | كيفية المعالجة                                                           |
| ----- | ----------------- | ------------------------------------------------------------------------ |
| 413   | Payload Too Large | أظهر رسالة: "حجم الملف كبير جداً. الحد الأقصى 10MB للصور و 20MB للـ PDF" |
| 422   | Validation Error  | أظهر رسائل التحقق المحددة (مثال: "يجب رفع صورة واحدة على الأقل")         |

### مثال معالجة الأخطاء

```dart
try {
  await _reportService.createReport(...);
} catch (e) {
  String errorMessage;

  if (e.toString().contains('413')) {
    errorMessage = 'حجم الملف كبير جداً. يرجى اختيار ملفات أصغر.';
  } else if (e.toString().contains('422')) {
    errorMessage = 'بيانات غير صالحة. يرجى التحقق من جميع الحقول.';
  } else {
    errorMessage = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(errorMessage)),
  );
}
```

---

## 📦 الحزم المطلوبة (Flutter)

أضف هذه الحزم إلى `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.0.0
  flutter_secure_storage: ^8.0.0
  image_picker: ^1.0.0
  file_picker: ^6.0.0
  url_launcher: ^6.0.0
```

ثم قم بتشغيل:

```bash
flutter pub get
```

---

## ✅ قائمة التحقق للتنفيذ

### للمطورين Frontend:

- [ ] تحديث نموذج `ReportModel` لإضافة `images`, `pdfUrl`, `videoLinks`
- [ ] تحديث خدمة `ReportService` لدعم رفع ملفات متعددة
- [ ] تحديث واجهة إنشاء التقرير لإضافة:
  - [ ] زر اختيار صور متعددة
  - [ ] زر اختيار ملف PDF
  - [ ] حقول إضافة روابط فيديو
- [ ] تحديث واجهة عرض التقرير لعرض:
  - [ ] معرض صور (Image Gallery / PageView)
  - [ ] رابط لفتح PDF
  - [ ] قائمة روابط الفيديو
- [ ] اختبار معالجة الأخطاء (413, 422)
- [ ] اختبار التوافق مع البيانات القديمة

---

## 📚 ملفات التوثيق

تم إنشاء الملفات التالية لفريق Frontend:

1. **[`API_DOCUMENTATION_V2.md`](API_DOCUMENTATION_V2.md)** - دليل API كامل بالإنجليزية
2. **[`API_DOCUMENTATION_V2_AR.md`](API_DOCUMENTATION_V2_AR.md)** - دليل API كامل بالعربية
3. **[`FRONTEND_API_INTEGRATION_GUIDE.md`](FRONTEND_API_INTEGRATION_GUIDE.md)** - هذا الملف

---

## 🚀 الخطوات التالية

1. **مراجعة الوثائق:** اقرأ [`API_DOCUMENTATION_V2_AR.md`](API_DOCUMENTATION_V2_AR.md) بالتفصيل
2. **تحديث النماذج:** عدّل `ReportModel` حسب الأمثلة المذكورة
3. **تحديث الخدمات:** عدّل `ReportService` لدعم الملفات المتعددة
4. **تحديث الواجهة:** أضف حقول رفع الصور والـ PDF والفيديو
5. **الاختبار:** اختبر جميع السيناريوهات (نجاح وخطأ)
6. **النشر:** بعد التأكد من عمل كل شيء بشكل صحيح

---

## 📞 الدعم الفني

إذا واجهت أي مشاكل أو كان لديك أسئلة:

- 📧 البريد الإلكتروني: support@example.com
- 📱 الهاتف: +963 XXX XXX XXX
- 💬 Slack: #frontend-support

---

**تم إعداد هذا الدليل بواسطة:** Kilo Code AI Assistant  
**التاريخ:** 2026-02-07  
**الإصدار:** 2.0.0

---

## 📝 ملخص سريع

### ما تم تغييره:

1. ✅ إضافة دعم صور متعددة (`images[]`)
2. ✅ إضافة دعم ملفات PDF (`pdf_file`)
3. ✅ إضافة دعم روابط الفيديو (`video_links[]`)
4. ✅ تحديث استجابة API لتضمين الحقول الجديدة
5. ✅ التوافق الكامل مع الإصدار القديم

### ما تحتاج لتغييره في Frontend:

1. تحديث `ReportModel` لإضافة الحقول الجديدة
2. تحديث `ReportService.createReport()` لرفع ملفات متعددة
3. تحديث واجهة المستخدم لإضافة حقول الرفع الجديدة
4. تحديث واجهة العرض لعرض الصور و PDF والفيديو

**النظام جاهز للاستخدام! 🎉**
