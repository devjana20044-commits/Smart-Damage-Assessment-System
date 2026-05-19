import 'package:flutter/material.dart';

/// Localization class for managing app translations
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App Title
      'appTitle': 'Smart Damage Assessment',
      'appSubtitle': 'AI-Powered Damage Reporting',

      // Common
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'save': 'Save',
      'cancel': 'Cancel',
      'submit': 'Submit',
      'delete': 'Delete',
      'edit': 'Edit',
      'view': 'View',
      'search': 'Search',
      'filter': 'Filter',
      'clear': 'Clear',
      'apply': 'Apply',

      // Auth
      'login': 'Login',
      'logout': 'Logout',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'fullName': 'Full Name',
      'welcomeBack': 'Welcome Back',
      'signInToContinue': 'Sign in to continue',
      'dontHaveAccount': 'Don\'t have an account?',
      'alreadyHaveAccount': 'Already have an account?',
      'signUp': 'Sign Up',
      'signIn': 'Sign In',
      'createAccount': 'Create Account',
      'joinToStart': 'Join us to start reporting damage',

      // Reports
      'reports': 'Reports',
      'myReports': 'My Reports',
      'createReport': 'Create Report',
      'reportDetails': 'Report Details',
      'location': 'Location',
      'notes': 'Notes',
      'photo': 'Photo',
      'takePhoto': 'Take Photo',
      'getCurrentLocation': 'Get Current Location',
      'locationName': 'Location Name',
      'locationDescription': 'Enter location name or description',
      'additionalDetails': 'Additional details about the damage',
      'submitReport': 'Submit Report',
      'noReportsYet': 'No Reports Yet',
      'startByCreating': 'Start by creating your first damage report',
      'createFirstReport': 'Create First Report',

      // Status
      'pending': 'Pending',
      'processing': 'Processing',
      'completed': 'Completed',
      'rejected': 'Rejected',

      // Damage Levels
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',
      'critical': 'Critical',

      // Statistics
      'statistics': 'Statistics',
      'reportStatus': 'Report Status',
      'totalReports': 'Total Reports',
      'completedReports': 'Completed Reports',
      'pendingReports': 'Pending Reports',
      'rejectedReports': 'Rejected Reports',
      'damageLevels': 'Damage Levels',
      'distributionOverview': 'Distribution Overview',
      'chartPlaceholder': 'Chart visualization would go here',
      'noDataAvailable': 'No Data Available',
      'createReportsToSeeStats': 'Create reports to see statistics',
      'damageSeverityDistribution': 'Damage Severity Distribution',
      'loadingStatistics': 'Loading statistics...',

      // Settings
      'settings': 'Settings',
      'language': 'Language',
      'english': 'English',
      'arabic': 'Arabic',
      'backendConfiguration': 'Backend Configuration',
      'ipAddress': 'IP Address',
      'port': 'Port',
      'path': 'Path',
      'testConnection': 'Test Connection',
      'reset': 'Reset',
      'saveSettings': 'Save Settings',
      'fullUrl': 'Full URL',
      'connectionTest': 'Connection Test',
      'responseStatus': 'Response Status',
      'response': 'Response',
      'connectionSuccess': 'Connection successful',
      'connectionFailed': 'Connection failed',

      // Report Details
      'basicInformation': 'Basic Information',
      'description': 'Description',
      'damageAssessment': 'Damage Assessment',
      'damageLevel': 'Damage Level',
      'status': 'Status',
      'reportedBy': 'Reported By',
      'coordinates': 'Coordinates',
      'normalizedLocation': 'Normalized Location',
      'userDescription': 'User Description',
      'aiAnalysis': 'AI Analysis',
      'images': 'Images',
      'pdfDocument': 'PDF Document',
      'tapToView': 'Tap to view',
      'videoLinks': 'Video Links',
      'video': 'Video',
      'failedToLoadReport': 'Failed to load report',
      'pleaseTryAgain': 'Please try again later',
      'retry': 'Retry',
      'editReport': 'Edit Report',
      'deleteReport': 'Delete Report',
      'confirmDelete': 'Confirm Delete',
      'deleteConfirmation': 'Are you sure you want to delete this report?',
      'reportUpdated': 'Report updated successfully',
      'reportDeleted': 'Report deleted successfully',
      'locationNotAvailable': 'Location not available',
      'imageNotAvailable': 'Image not available',
      'noImages': 'No images',
      'loadingReportDetails': 'Loading report details...',
      'pendingEditNote':
          'This report can be edited because it is still pending',
      'copied': 'copied',
      'date': 'Date',

      // Location & Create Report
      'locationServiceDisabled':
          'Location service is disabled. Please enable GPS.',
      'locationPermissionDenied': 'Location permission denied',
      'locationPermissionDeniedForever':
          'Location permission denied permanently. Please enable in app settings.',
      'locationObtained': 'Location obtained successfully',
      'locationFailed': 'Failed to get location',
      'locationTimeout':
          'Location request timed out, trying with lower accuracy...',
      'gettingLocation': 'Getting Location...',
      'openSettings': 'Open Settings',
      'cameraPermissionDeniedForever':
          'Camera permission denied permanently. Please enable in app settings.',
      'cameraPermissionDenied': 'Camera permission denied',
      'photoCaptured': 'Photo captured successfully',
      'photoFailed': 'Failed to take photo',
      'photosPermissionDeniedForever':
          'Photos permission denied permanently. Please enable in app settings.',
      'photosPermissionDenied': 'Photos permission denied',
      'imagesSelected': '{count} image(s) selected',
      'imagesFailed': 'Failed to pick images',
      'pdfSelected': 'PDF file selected',
      'pdfFailed': 'Failed to pick PDF',
      'invalidUrl': 'Please enter a valid URL (http:// or https://)',
      'videoLinkAdded': 'Video link added',
      'addPhotoRequired': 'Please add at least one photo',
      'creatingReport': 'Creating report...',
      'reportCreated': 'Report created successfully',
      'notesOptional': 'Notes (Optional)',
      'photos': 'Photos',
      'fromGallery': 'From Gallery',
      'imagesCount': '{count} image(s) selected',
      'pdfOptional': 'PDF Document (Optional)',
      'selectPdf': 'Select PDF File',
      'videoLinksOptional': 'Video Links (Optional)',
      'videoUrl': 'Video URL',
      'requiredField': 'This field is required',
      'invalidEmail': 'Please enter a valid email',
      'passwordTooShort': 'Password must be at least 8 characters',
      'passwordsDoNotMatch': 'Passwords do not match',
      'invalidIP': 'Please enter a valid IP address',
      'invalidPort': 'Please enter a valid port number (1-65535)',
      'pathMustStartWithSlash': 'Path must start with /',
      'ipChangedRelogin': 'IP address changed - please log in again',
      'saveSettingsFailed': 'Failed to save settings',
      'connectionTimeout': 'Connection timed out',
      'checkIpAndPort': 'Please check the IP address and port number.',
      'connectionError': 'Connection error',
      'settingsReset': 'Settings have been reset',
      'connectedSuccessfully': 'Connected successfully!',
      'ok': 'OK',
      'ipExample': 'e.g., 192.168.1.100',
      'enterIP': 'Please enter IP address',
      'portExample': 'e.g., 8000',
      'enterPort': 'Please enter port number',
      'enterPath': 'Please enter path',
      'pathExample': 'e.g., /api',
      'settingsSavedSuccess': 'Settings saved successfully!',
      'connected': 'Connected',
      'disconnected': 'Disconnected',
      'tapToTest': 'Tap "Test Connection" to verify',
      'fullUrlTitle': 'Full URL Address',
      'serverSettings': 'Server Settings',

      // Report Details Redesign
      'projectDetails': 'Report Details',
      'primarySite': 'Primary Site',
      'surveyDate': 'Survey Date',
      'reportId': 'Report ID',
      'viewOnMap': 'View on Map',
      'assessmentProgress': 'Assessment Progress',
      'verified': 'Verified',
      'aiEstimated': 'AI Estimated',
      'updateReport': 'Update Report',
      'exportPdf': 'Export PDF',
      'priority': 'Priority',
      'geographicalContext': 'Geographical Context',

      // Home Screen Redesign
      'searchReports': 'Search reports...',
      'details': 'Details',
      'home': 'Home',
      'map': 'Map',
      'noMatchingReports': 'No matching reports',
      'editProfile': 'Edit Profile',
      'editProfileTitle': 'Edit Account Information',
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',
      'confirmNewPassword': 'Confirm New Password',
      'passwordChangeOptional': 'Leave empty to keep current password',
      'profileUpdated': 'Profile updated successfully',
      'technicalProgress': 'Technical Progress',
      'aiCalculation': 'AI Calculation',
      'automatedProgress': 'Automated Progress',
      'manualVerification': 'Manual Verification',
      'shareReport': 'Share',
      'updateTechnicalReport': 'Update Technical Report',
      'inspectionDate': 'Inspection Date',

      // Drafts
      'drafts': 'Drafts',
      'saveDraft': 'Save Draft',
      'noDraftsYet': 'No Drafts Yet',
      'draftsHint':
          'Save reports as drafts to send them later when you have internet',
      'draftSaved': 'Draft saved successfully',
      'draftDeleted': 'Draft deleted successfully',
    },
    'ar': {
      // App Title
      'appTitle': 'نظام تقييم الأضرار الذكي',
      'appSubtitle': 'إعداد تقارير الأضرار بالذكاء الاصطناعي',

      // Common
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجاح',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'submit': 'إرسال',
      'delete': 'حذف',
      'edit': 'تعديل',
      'view': 'عرض',
      'search': 'بحث',
      'filter': 'تصفية',
      'clear': 'مسح',
      'apply': 'تطبيق',

      // Auth
      'login': 'تسجيل الدخول',
      'logout': 'تسجيل الخروج',
      'register': 'التسجيل',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'fullName': 'الاسم الكامل',
      'welcomeBack': 'مرحباً بعودتك',
      'signInToContinue': 'سجل الدخول للمتابعة',
      'dontHaveAccount': 'ليس لديك حساب؟',
      'alreadyHaveAccount': 'لديك حساب بالفعل؟',
      'signUp': 'إنشاء حساب',
      'signIn': 'تسجيل الدخول',
      'createAccount': 'إنشاء حساب',
      'joinToStart': 'انضم إلينا لبدء الإبلاغ عن الأضرار',

      // Reports
      'reports': 'التقارير',
      'myReports': 'تقاريري',
      'createReport': 'إنشاء تقرير',
      'reportDetails': 'تفاصيل التقرير',
      'location': 'الموقع',
      'notes': 'ملاحظات',
      'photo': 'صورة',
      'takePhoto': 'التقط صورة',
      'getCurrentLocation': 'الحصول على الموقع الحالي',
      'locationName': 'اسم الموقع',
      'locationDescription': 'أدخل اسم الموقع أو وصفه',
      'additionalDetails': 'تفاصيل إضافية عن الضرر',
      'submitReport': 'إرسال التقرير',
      'noReportsYet': 'لا توجد تقارير بعد',
      'startByCreating': 'ابدأ بإنشاء أول تقرير ضرر',
      'createFirstReport': 'إنشاء التقرير الأول',

      // Status
      'pending': 'قيد الانتظار',
      'processing': 'قيد المعالجة',
      'completed': 'مكتمل',
      'rejected': 'مرفوض',

      // Damage Levels
      'low': 'منخفض',
      'medium': 'متوسط',
      'high': 'مرتفع',
      'critical': 'حرج',

      // Statistics
      'statistics': 'الإحصائيات',
      'reportStatus': 'حالة التقارير',
      'totalReports': 'إجمالي التقارير',
      'completedReports': 'التقارير المكتملة',
      'pendingReports': 'التقارير قيد الانتظار',
      'rejectedReports': 'التقارير المرفوضة',
      'damageLevels': 'مستويات الضرر',
      'distributionOverview': 'نظرة عامة على التوزيع',
      'chartPlaceholder': 'ستظهر المخططات هنا',
      'noDataAvailable': 'لا توجد بيانات متاحة',
      'createReportsToSeeStats': 'أنشئ تقارير لرؤية الإحصائيات',
      'damageSeverityDistribution': 'توزيع شدة الضرر',
      'loadingStatistics': 'جاري تحميل الإحصائيات...',

      // Settings
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'english': 'الإنجليزية',
      'arabic': 'العربية',
      'backendConfiguration': 'إعدادات الباكند',
      'ipAddress': 'عنوان IP',
      'port': 'رقم المنفذ',
      'path': 'المسار',
      'testConnection': 'اختبار الاتصال',
      'reset': 'إعادة تعيين',
      'saveSettings': 'حفظ الإعدادات',
      'fullUrl': 'العنوان الكامل',
      'connectionTest': 'اختبار الاتصال',
      'responseStatus': 'حالة الاستجابة',
      'response': 'الاستجابة',
      'connectionSuccess': 'نجح الاتصال',
      'connectionFailed': 'فشل الاتصال',

      // Report Details
      'basicInformation': 'المعلومات الأساسية',
      'description': 'الوصف',
      'damageAssessment': 'تقييم الضرر',
      'damageLevel': 'مستوى الضرر',
      'status': 'الحالة',
      'reportedBy': 'مقدم البلاغ',
      'coordinates': 'الإحداثيات',
      'normalizedLocation': 'الموقع الموحد',
      'userDescription': 'وصف المستخدم',
      'aiAnalysis': 'تحليل الذكاء الاصطناعي',
      'images': 'الصور',
      'pdfDocument': 'مستند PDF',
      'tapToView': 'انقر للعرض',
      'videoLinks': 'روابط الفيديو',
      'video': 'فيديو',
      'failedToLoadReport': 'فشل تحميل التقرير',
      'pleaseTryAgain': 'يرجى المحاولة لاحقاً',
      'retry': 'إعادة المحاولة',
      'editReport': 'تعديل التقرير',
      'deleteReport': 'حذف التقرير',
      'confirmDelete': 'تأكيد الحذف',
      'deleteConfirmation': 'هل أنت متأكد من حذف هذا التقرير؟',
      'reportUpdated': 'تم تحديث التقرير بنجاح',
      'reportDeleted': 'تم حذف التقرير بنجاح',
      'locationNotAvailable': 'الموقع غير متاح',
      'imageNotAvailable': 'الصورة غير متاحة',
      'noImages': 'لا توجد صور',
      'loadingReportDetails': 'جاري تحميل تفاصيل التقرير...',
      'pendingEditNote': 'يمكن تعديل هذا التقرير لأنه لا يزال قيد الانتظار',
      'copied': 'تم النسخ',
      'date': 'التاريخ',

      // Location & Create Report
      'locationServiceDisabled': 'خدمات الموقع معطلة. يرجى تفعيل GPS.',
      'locationPermissionDenied': 'تم رفض إذن الموقع',
      'locationPermissionDeniedForever':
          'تم رفض إذن الموقع نهائياً. يرجى تفعيله من إعدادات التطبيق.',
      'locationObtained': 'تم الحصول على الموقع بنجاح',
      'locationFailed': 'فشل في الحصول على الموقع',
      'locationTimeout': 'انتهت مهلة طلب الموقع، جاري المحاولة بدقة أقل...',
      'gettingLocation': 'جاري الحصول على الموقع...',
      'openSettings': 'فتح الإعدادات',
      'cameraPermissionDeniedForever':
          'تم رفض إذن الكاميرا نهائياً. يرجى تفعيله من إعدادات التطبيق.',
      'cameraPermissionDenied': 'تم رفض إذن الكاميرا',
      'photoCaptured': 'تم التقاط الصورة بنجاح',
      'photoFailed': 'فشل التقاط الصورة',
      'photosPermissionDeniedForever':
          'تم رفض إذن الصور نهائياً. يرجى تفعيله من إعدادات التطبيق.',
      'photosPermissionDenied': 'تم رفض إذن الصور',
      'imagesSelected': 'تم تحديد {count} صورة',
      'imagesFailed': 'فشل في اختيار الصور',
      'pdfSelected': 'تم اختيار ملف PDF',
      'pdfFailed': 'فشل في اختيار PDF',
      'invalidUrl': 'يرجى إدخال رابط صحيح (http:// أو https://)',
      'videoLinkAdded': 'تمت إضافة رابط الفيديو',
      'addPhotoRequired': 'يرجى إضافة صورة واحدة على الأقل',
      'creatingReport': 'جاري إنشاء التقرير...',
      'reportCreated': 'تم إنشاء التقرير بنجاح',
      'notesOptional': 'ملاحظات (اختياري)',
      'photos': 'الصور',
      'fromGallery': 'من المعرض',
      'imagesCount': 'تم تحديد {count} صورة',
      'pdfOptional': 'مستند PDF (اختياري)',
      'selectPdf': 'اختر ملف PDF',
      'videoLinksOptional': 'روابط الفيديو (اختياري)',
      'videoUrl': 'رابط الفيديو',
      'requiredField': 'هذا الحقل مطلوب',
      'invalidEmail': 'يرجى إدخال بريد إلكتروني صحيح',
      'passwordTooShort': 'يجب أن تكون كلمة المرور 8 أحرف على الأقل',
      'passwordsDoNotMatch': 'كلمات المرور غير متطابقة',
      'invalidIP': 'يرجى إدخال عنوان IP صحيح',
      'invalidPort': 'يرجى إدخال رقم منفذ صحيح (1-65535)',
      'pathMustStartWithSlash': 'يجب أن يبدأ المسار بـ /',
      'ipChangedRelogin': 'تم تغيير عنوان IP - يرجى تسجيل الدخول مرة أخرى',
      'saveSettingsFailed': 'فشل حفظ الإعدادات',
      'connectionTimeout': 'انتهت مهلة الاتصال',
      'checkIpAndPort': 'يرجى التحقق من عنوان IP ورقم المنفذ.',
      'connectionError': 'خطأ في الاتصال',
      'settingsReset': 'تم إعادة تعيين الإعدادات',
      'connectedSuccessfully': 'متصل بنجاح!',
      'ok': 'حسناً',
      'ipExample': 'مثال: 192.168.1.100',
      'enterIP': 'يرجى إدخال عنوان IP',
      'portExample': 'مثال: 8000',
      'enterPort': 'يرجى إدخال رقم المنفذ',
      'enterPath': 'يرجى إدخال المسار',
      'pathExample': 'مثال: /api',
      'settingsSavedSuccess': 'تم حفظ الإعدادات بنجاح!',
      'connected': 'متصل',
      'disconnected': 'غير متصل',
      'tapToTest': 'اضغط "اختبار الاتصال" للتحقق',
      'fullUrlTitle': 'عنوان URL الكامل',
      'serverSettings': 'إعدادات السيرفر',

      // Report Details Redesign
      'projectDetails': 'تفاصيل التقرير',
      'primarySite': 'الموقع الرئيسي',
      'surveyDate': 'تاريخ المسح',
      'reportId': 'رقم التقرير',
      'viewOnMap': 'عرض على الخريطة',
      'assessmentProgress': 'تقدم التقييم',
      'verified': 'مثبت',
      'aiEstimated': 'تقدير الذكاء الاصطناعي',
      'updateReport': 'تحديث التقرير',
      'exportPdf': 'تصدير PDF',
      'priority': 'الأولوية',
      'geographicalContext': 'السياق الجغرافي',

      // Home Screen Redesign
      'searchReports': 'البحث في التقارير...',
      'details': 'التفاصيل',
      'home': 'الرئيسية',
      'map': 'الخريطة',
      'noMatchingReports': 'لا توجد تقارير مطابقة',
      'editProfile': 'تعديل الملف الشخصي',
      'editProfileTitle': 'تعديل معلومات الحساب',
      'currentPassword': 'كلمة المرور الحالية',
      'newPassword': 'كلمة المرور الجديدة',
      'confirmNewPassword': 'تأكيد كلمة المرور الجديدة',
      'passwordChangeOptional': 'اتركها فارغة للإبقاء على كلمة المرور الحالية',
      'profileUpdated': 'تم تحديث الملف الشخصي بنجاح',
      'technicalProgress': 'نسبة الإنجاز التقني',
      'aiCalculation': 'حساب ذكاء اصطناعي',
      'automatedProgress': 'إنجاز آلي',
      'manualVerification': 'تحقق يدوي',
      'shareReport': 'مشاركة',
      'updateTechnicalReport': 'تحديث التقرير الفني',
      'inspectionDate': 'تاريخ الفحص',

      // Drafts
      'drafts': 'المسودات',
      'saveDraft': 'حفظ كمسودة',
      'noDraftsYet': 'لا توجد مسودات بعد',
      'draftsHint': 'احفظ التقارير كمسودات لإرسالها لاحقاً عند توفر الإنترنت',
      'draftSaved': 'تم حفظ المسودة بنجاح',
      'draftDeleted': 'تم حذف المسودة بنجاح',
    },
  };

  /// Get translation for a key
  String translate(String key) {
    try {
      return _localizedValues[locale.languageCode]![key] ?? key;
    } catch (e) {
      print('❌ Localization error: $e for key: $key');
      return key;
    }
  }

  // Convenience getters
  String get appTitle => translate('appTitle');
  String get appSubtitle => translate('appSubtitle');
  String get login => translate('login');
  String get logout => translate('logout');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get reports => translate('reports');
  String get myReports => translate('myReports');
  String get createReport => translate('createReport');
  String get settings => translate('settings');
  String get language => translate('language');
  String get english => translate('english');
  String get arabic => translate('arabic');
  String get statistics => translate('statistics');
  String get reportStatus => translate('reportStatus');
  String get totalReports => translate('totalReports');
  String get completedReports => translate('completedReports');
  String get pendingReports => translate('pendingReports');
  String get rejectedReports => translate('rejectedReports');
  String get damageLevels => translate('damageLevels');
  String get distributionOverview => translate('distributionOverview');
  String get chartPlaceholder => translate('chartPlaceholder');
  String get noDataAvailable => translate('noDataAvailable');
  String get createReportsToSeeStats => translate('createReportsToSeeStats');
  String get damageSeverityDistribution =>
      translate('damageSeverityDistribution');
  String get loadingStatistics => translate('loadingStatistics');
  String get search => translate('search');
  String get filter => translate('filter');
  String get loading => translate('loading');
  String get cancel => translate('cancel');
  String get clear => translate('clear');
  String get noReportsYet => translate('noReportsYet');
  String get startByCreating => translate('startByCreating');
  String get createFirstReport => translate('createFirstReport');
  // Auth
  String get welcomeBack => translate('welcomeBack');
  String get signInToContinue => translate('signInToContinue');
  String get dontHaveAccount => translate('dontHaveAccount');
  String get signUp => translate('signUp');
  String get signIn => translate('signIn');
  String get alreadyHaveAccount => translate('alreadyHaveAccount');
  String get createAccount => translate('createAccount');
  String get joinToStart => translate('joinToStart');
  // Damage levels
  String get low => translate('low');
  String get medium => translate('medium');
  String get high => translate('high');
  String get critical => translate('critical');
  // Status
  String get pending => translate('pending');
  String get processing => translate('processing');
  String get completed => translate('completed');
  String get rejected => translate('rejected');

  // Report Details
  String get basicInformation => translate('basicInformation');
  String get description => translate('description');
  String get damageAssessment => translate('damageAssessment');
  String get damageLevel => translate('damageLevel');
  String get status => translate('status');
  String get reportedBy => translate('reportedBy');
  String get coordinates => translate('coordinates');
  String get normalizedLocation => translate('normalizedLocation');
  String get userDescription => translate('userDescription');
  String get aiAnalysis => translate('aiAnalysis');
  String get images => translate('images');
  String get pdfDocument => translate('pdfDocument');
  String get tapToView => translate('tapToView');
  String get videoLinks => translate('videoLinks');
  String get video => translate('video');
  String get failedToLoadReport => translate('failedToLoadReport');
  String get pleaseTryAgain => translate('pleaseTryAgain');
  String get retry => translate('retry');
  String get editReport => translate('editReport');
  String get deleteReport => translate('deleteReport');
  String get confirmDelete => translate('confirmDelete');
  String get deleteConfirmation => translate('deleteConfirmation');
  String get reportUpdated => translate('reportUpdated');
  String get reportDeleted => translate('reportDeleted');
  String get locationNotAvailable => translate('locationNotAvailable');
  String get imageNotAvailable => translate('imageNotAvailable');
  String get noImages => translate('noImages');
  String get loadingReportDetails => translate('loadingReportDetails');
  String get pendingEditNote => translate('pendingEditNote');
  String get copied => translate('copied');
  String get date => translate('date');
  String get delete => translate('delete');
  String get save => translate('save');
  String get reportDetails => translate('reportDetails');
  String get location => translate('location');
  String get locationName => translate('locationName');
  String get locationDescription => translate('locationDescription');
  String get requiredField => translate('requiredField');
  String get additionalDetails => translate('additionalDetails');
  String get getCurrentLocation => translate('getCurrentLocation');
  String get takePhoto => translate('takePhoto');
  String get submitReport => translate('submitReport');
  String get error => translate('error');
  String get ipChangedRelogin => translate('ipChangedRelogin');
  String get saveSettingsFailed => translate('saveSettingsFailed');
  String get connectionTimeout => translate('connectionTimeout');
  String get checkIpAndPort => translate('checkIpAndPort');
  String get connectionError => translate('connectionError');
  String get settingsReset => translate('settingsReset');
  String get connectedSuccessfully => translate('connectedSuccessfully');
  String get ok => translate('ok');
  String get ipExample => translate('ipExample');
  String get enterIP => translate('enterIP');
  String get portExample => translate('portExample');
  String get enterPort => translate('enterPort');
  String get enterPath => translate('enterPath');
  String get pathExample => translate('pathExample');
  String get settingsSavedSuccess => translate('settingsSavedSuccess');
  String get connected => translate('connected');
  String get disconnected => translate('disconnected');
  String get tapToTest => translate('tapToTest');
  String get fullUrlTitle => translate('fullUrlTitle');
  String get serverSettings => translate('serverSettings');
  String get projectDetails => translate('projectDetails');
  String get primarySite => translate('primarySite');
  String get surveyDate => translate('surveyDate');
  String get reportId => translate('reportId');
  String get viewOnMap => translate('viewOnMap');
  String get assessmentProgress => translate('assessmentProgress');
  String get verified => translate('verified');
  String get aiEstimated => translate('aiEstimated');
  String get updateReport => translate('updateReport');
  String get exportPdf => translate('exportPdf');
  String get priority => translate('priority');
  String get geographicalContext => translate('geographicalContext');
  String get searchReports => translate('searchReports');
  String get details => translate('details');
  String get home => translate('home');
  String get map => translate('map');
  String get noMatchingReports => translate('noMatchingReports');
  String get editProfile => translate('editProfile');
  String get editProfileTitle => translate('editProfileTitle');
  String get currentPassword => translate('currentPassword');
  String get newPassword => translate('newPassword');
  String get confirmNewPassword => translate('confirmNewPassword');
  String get passwordChangeOptional => translate('passwordChangeOptional');
  String get profileUpdated => translate('profileUpdated');
  String get technicalProgress => translate('technicalProgress');
  String get aiCalculation => translate('aiCalculation');
  String get automatedProgress => translate('automatedProgress');
  String get manualVerification => translate('manualVerification');
  String get shareReport => translate('shareReport');
  String get updateTechnicalReport => translate('updateTechnicalReport');
  String get inspectionDate => translate('inspectionDate');
  String get fullName => translate('fullName');
  String get invalidEmail => translate('invalidEmail');
  String get passwordTooShort => translate('passwordTooShort');
  String get passwordsDoNotMatch => translate('passwordsDoNotMatch');
  String get backendConfiguration => translate('backendConfiguration');
  String get ipAddress => translate('ipAddress');
  String get port => translate('port');
  String get path => translate('path');
  String get testConnection => translate('testConnection');
  String get reset => translate('reset');
  String get saveSettings => translate('saveSettings');
  String get fullUrl => translate('fullUrl');
  String get connectionSuccess => translate('connectionSuccess');
  String get connectionFailed => translate('connectionFailed');
  String get invalidIP => translate('invalidIP');
  String get invalidPort => translate('invalidPort');
  String get pathMustStartWithSlash => translate('pathMustStartWithSlash');
  String get drafts => translate('drafts');
  String get saveDraft => translate('saveDraft');
  String get noDraftsYet => translate('noDraftsYet');
  String get draftsHint => translate('draftsHint');
  String get draftSaved => translate('draftSaved');
  String get draftDeleted => translate('draftDeleted');
}

/// Localizations delegate for Flutter
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// Extension to easily access localization in context
extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
