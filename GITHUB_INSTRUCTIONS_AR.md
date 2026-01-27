# تعليمات رفع المشروع على GitHub باستخدام Git

## المتطلبات الأساسية

1. حساب على GitHub: [https://github.com](https://github.com)
2. Git مثبت على جهازك
3. مشروع Smart Damage Assessment System

---

## الخطوة 1: تثبيت Git (إذا لم يكن مثبتاً)

### على Windows:
1. تحميل Git من: [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. تثبيت البرنامج باستخدام الإعدادات الافتراضية
3. التحقق من التثبيت:
   ```bash
   git --version
   ```

### على macOS:
```bash
git --version
# إذا لم يكن مثبتاً، سيطلب منك التثبيت تلقائياً
```

### على Linux (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install git
```

---

## الخطوة 2: إعداد Git

### إعداد اسم المستخدم والبريد الإلكتروني:
```bash
git config --global user.name "اسمك"
git config --global user.email "بريدك_الإلكتروني@example.com"
```

### التحقق من الإعدادات:
```bash
git config --list
```

---

## الخطوة 3: تهيئة مستودع Git

### الانتقال إلى مجلد المشروع:
```bash
cd "c:\Users\DELL\Documents\Smart Damage Assessment System"
```

### تهيئة مستودع Git جديد:
```bash
git init
```

### التحقق من الحالة:
```bash
git status
```

---

## الخطوة 4: إعداد ملف .gitignore

إنشاء ملف `.gitignore` في المجلد الرئيسي لاستبعاد الملفات غير المرغوب فيها:

```gitignore
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Android
android/.gradle/
android/app/build/
android/local.properties
*.keystore
*.jks

# iOS
ios/Pods/
ios/.symlinks/
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec
ios/.generated/
ios/Runner.xcworkspace/
ios/Runner.xcodeproj/xcuserdata/
ios/Runner/GeneratedPluginRegistrant.*

# macOS
macos/Pods/
macos/.symlinks/
macos/Flutter/Flutter.framework
macos/Flutter/Flutter.podspec
macos/.generated/
macos/Runner.xcworkspace/
macos/Runner.xcodeproj/xcuserdata/

# Linux
linux/flutter/ephemeral/
linux/.flutter-plugins-dependencies

# IDE
.idea/
.vscode/
*.iml
*.swp
*.swo
*~

# Laravel (إذا كان موجوداً)
/vendor/
/node_modules/
/.env
/storage/*.key
/public/storage
/public/hot
Homestead.json
Homestead.yaml
npm-debug.log
yarn-error.log

# OS
.DS_Store
Thumbs.db

# Logs
*.log
```

---

## الخطوة 5: إضافة الملفات إلى Git

### إضافة جميع الملفات (مع مراعاة .gitignore):
```bash
git add .
```

### أو إضافة ملفات محددة:
```bash
git add README.md
git add AGENTS.md
git add smart_damage_assessment/
```

### التحقق من الملفات المضافة:
```bash
git status
```

---

## الخطوة 6: إنشاء أول Commit

```bash
git commit -m "Initial commit: Smart Damage Assessment System"
```

### قواعد كتابة رسائل Commit:
- اكتب بالإنجليزية (المعتاد في GitHub)
- استخدم المضارع: "Add" وليس "Added"
- كن موجزاً وواضحاً
- أمثلة:
  - `feat: add login screen`
  - `fix: resolve API connection issue`
  - `docs: update README`

---

## الخطوة 7: إنشاء مستودع على GitHub

### الطريقة الأولى: عبر موقع GitHub

1. سجل الدخول إلى [https://github.com](https://github.com)
2. اضغط على **+** في الزاوية العلوية اليمنى
3. اختر **New repository**
4. املأ البيانات:
   - **Repository name**: `smart-damage-assessment-system`
   - **Description**: `Full-stack damage assessment system with Flutter mobile app and Laravel backend`
   - **Public/Private**: اختر حسب رغبتك
   - **Initialize this repository**: ❌ لا تضع علامة
5. اضغط **Create repository**

### الطريقة الثانية: عبر GitHub CLI (gh)
```bash
# تثبيت GitHub CLI
# Windows: winget install --id GitHub.cli
# macOS: brew install gh
# Linux: sudo apt install gh

# تسجيل الدخول
gh auth login

# إنشاء مستودع
gh repo create smart-damage-assessment-system --public --source=. --remote=origin --push
```

---

## الخطوة 8: ربط المستودع المحلي بـ GitHub

### إضافة Remote URL:
```bash
git remote add origin https://github.com/USERNAME/smart-damage-assessment-system.git
```

استبدل `USERNAME` باسم المستخدم الخاص بك على GitHub.

### التحقق من Remote:
```bash
git remote -v
```

### تعديل Remote (إذا لزم الأمر):
```bash
git remote set-url origin https://github.com/USERNAME/smart-damage-assessment-system.git
```

---

## الخطوة 9: رفع الكود إلى GitHub

### الرفع إلى الفرع الرئيسي (main):
```bash
git branch -M main
git push -u origin main
```

### أو إذا كنت تستخدم master:
```bash
git push -u origin master
```

---

## الخطوة 10: المصادقة مع GitHub

### الطريقة الأولى: Personal Access Token (موصى به)

1. اذهب إلى GitHub → Settings → Developer settings → Personal access tokens
2. اضغط **Generate new token** → **Generate new token (classic)**
3. أعطِ الاسم: `Git Push Token`
4. حدد الصلاحيات:
   - ✅ repo (Full control of private repositories)
5. اضغط **Generate token**
6. انسخ التوكن (لن يظهر مرة أخرى)

### عند الرفع:
```bash
# سيطلب منك اسم المستخدم وكلمة المرور
Username: USERNAME
Password: YOUR_PERSONAL_ACCESS_TOKEN
```

### الطريقة الثانية: GitHub CLI
```bash
gh auth login
# اختر GitHub.com
# اختر HTTPS
# اختر Login with a web browser
```

---

## سير العمل اليومي (Git Workflow)

### 1. فحص التغييرات:
```bash
git status
```

### 2. إضافة الملفات المعدلة:
```bash
git add .
# أو ملفات محددة
git add lib/main.dart
```

### 3. إنشاء Commit:
```bash
git commit -m "feat: implement report submission"
```

### 4. الرفع إلى GitHub:
```bash
git push
```

### 5. سحب التغييرات من GitHub:
```bash
git pull
```

---

## أوامر Git الأساسية

| الأمر | الوصف |
|--------|-------|
| `git init` | تهيئة مستودع جديد |
| `git status` | عرض حالة الملفات |
| `git add .` | إضافة جميع الملفات |
| `git commit -m "message"` | حفظ التغييرات |
| `git push` | رفع التغييرات إلى GitHub |
| `git pull` | سحب التغييرات من GitHub |
| `git log` | عرض تاريخ Commits |
| `git branch` | عرض الفروع |
| `git checkout -b branch-name` | إنشاء وتبديل لفرع جديد |
| `git merge branch-name` | دمج فرع في الفرع الحالي |

---

## التعامل مع الفروع (Branches)

### إنشاء فرع جديد:
```bash
git checkout -b feature/login-screen
```

### عرض الفروع:
```bash
git branch
```

### التبديل بين الفروع:
```bash
git checkout main
```

### دمج فرع في main:
```bash
git checkout main
git merge feature/login-screen
```

### حذف فرع:
```bash
git branch -d feature/login-screen
```

---

## إلغاء التغييرات (Undo)

### إلغاء تغييرات ملف (قبل add):
```bash
git restore filename.dart
```

### إلغاء add:
```bash
git restore --staged filename.dart
```

### إلغاء آخر commit:
```bash
git reset --soft HEAD~1  # يحتفظ بالتغييرات
git reset --hard HEAD~1  # يحذف التغييرات
```

---

## حل المشاكل الشائعة

### مشكلة: "fatal: remote origin already exists"
```bash
git remote remove origin
git remote add origin https://github.com/USERNAME/REPO.git
```

### مشكلة: "Updates were rejected"
```bash
git pull origin main --rebase
git push origin main
```

### مشكلة: "Authentication failed"
- تأكد من استخدام Personal Access Token وليس كلمة المرور
- تأكد من صلاحيات التوكن

### مشكلة: ملفات كبيرة جداً
```bash
# تثبيت Git LFS
git lfs install

# تتبع أنواع الملفات الكبيرة
git lfs track "*.apk"
git lfs track "*.ipa"
git add .gitattributes
```

---

## نصائح مهمة

1. **Commit متكرر**: قم بعمل Commits صغيرة ومتكررة
2. **رسائل واضحة**: اكتب رسائل Commit واضحة ومفيدة
3. **استخدام الفروع**: استخدم فروعاً منفصلة للميزات الجديدة
4. **Pull قبل Push**: اسحب دائماً قبل الرفع لتجنب التعارضات
5. **.gitignore**: تأكد من إعداد ملف .gitignore بشكل صحيح
6. **نسخ احتياطي**: احتفظ بنسخة احتياطية قبل عمليات Git المعقدة

---

## هيكل المشروع المقترح على GitHub

```
smart-damage-assessment-system/
├── .gitignore
├── README.md
├── AGENTS.md
├── API Documentation.md
├── GITHUB_INSTRUCTIONS_AR.md
├── Connection Configuration.md
├── Flutter App Implementation.md
├── Laravel Backend Setup.md
├── plans/
│   └── flutter_app_implementation_plan.md
└── smart_damage_assessment/
    ├── pubspec.yaml
    ├── android/
    ├── ios/
    ├── lib/
    │   ├── main.dart
    │   ├── core/
    │   ├── models/
    │   ├── providers/
    │   ├── screens/
    │   ├── services/
    │   └── widgets/
    └── test/
```

---

## الموارد الإضافية

- [Git Documentation](https://git-scm.com/doc)
- [GitHub Guides](https://guides.github.com/)
- [Git Handbook](https://guides.github.com/introduction/git-handbook/)
- [Learn Git Branching](https://learngitbranching.js.org/)

---

## الدعم

إذا واجهت أي مشاكل، يمكنك:
1. البحث في [GitHub Community Forum](https://github.community/)
2. قراءة [Git Documentation](https://git-scm.com/doc)
3. طلب المساعدة من فريق التطوير

---

**ملاحظة**: تأكد من عدم رفع ملفات حساسة مثل:
- مفاتيح API
- كلمات المرور
- ملفات `.env`
- مفاتيح التوقيع (keystore/jks)
