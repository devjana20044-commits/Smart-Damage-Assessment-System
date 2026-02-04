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
      
      // Validation
      'requiredField': 'This field is required',
      'invalidEmail': 'Please enter a valid email',
      'passwordTooShort': 'Password must be at least 8 characters',
      'passwordsDoNotMatch': 'Passwords do not match',
      'invalidIP': 'Please enter a valid IP address',
      'invalidPort': 'Please enter a valid port (1-65535)',
      'pathMustStartWithSlash': 'Path must start with /',
    },
    'ar': {
      // App Title
      'appTitle': 'تقييم الأضرار الذكي',
      'appSubtitle': 'نظام إبلاغ الأضرار المدعوم بالذكاء الاصطناعي',
      
      // Common
      'loading': 'جار التحميل...',
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
      'register': 'تسجيل حساب',
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
      'takePhoto': 'التقاط صورة',
      'getCurrentLocation': 'الحصول على الموقع الحالي',
      'locationName': 'اسم الموقع',
      'locationDescription': 'أدخل اسم الموقع أو الوصف',
      'additionalDetails': 'تفاصيل إضافية عن الضرر',
      'submitReport': 'إرسال التقرير',
      'noReportsYet': 'لا توجد تقارير بعد',
      'startByCreating': 'ابدأ بإنشاء أول تقرير أضرار',
      'createFirstReport': 'إنشاء أول تقرير',
      
      // Status
      'pending': 'قيد الانتظار',
      'processing': 'قيد المعالجة',
      'completed': 'مكتمل',
      'rejected': 'مرفوض',
      
      // Damage Levels
      'low': 'طفيف',
      'medium': 'متوسط',
      'high': 'شديد',
      'critical': 'حرج',
      
      // Statistics
      'statistics': 'الإحصائيات',
      'reportStatus': 'حالة التقرير',
      'totalReports': 'إجمالي التقارير',
      'completedReports': 'التقارير المكتملة',
      'pendingReports': 'التقارير قيد الانتظار',
      'rejectedReports': 'التقارير المرفوضة',
      'damageLevels': 'مستويات الضرر',
      'distributionOverview': 'نظرة عامة على التوزيع',
      'chartPlaceholder': 'سيظهر هنا الرسم البياني',
      'noDataAvailable': 'لا توجد بيانات',
      'createReportsToSeeStats': 'قم بإنشاء تقارير لعرض الإحصائيات',
      'damageSeverityDistribution': 'توزيع شدة الضرر',
      'loadingStatistics': 'جار تحميل الإحصائيات...',
      
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
      'fullUrl': 'عنوان URL الكامل',
      'connectionTest': 'اختبار الاتصال',
      'responseStatus': 'حالة الاستجابة',
      'response': 'الاستجابة',
      'connectionSuccess': 'تم الاتصال بنجاح',
      'connectionFailed': 'فشل الاتصال',
      
      // Validation
      'requiredField': 'هذا الحقل مطلوب',
      'invalidEmail': 'يرجى إدخال بريد إلكتروني صحيح',
      'passwordTooShort': 'يجب أن تكون كلمة المرور 8 أحرف على الأقل',
      'passwordsDoNotMatch': 'كلمات المرور غير متطابقة',
      'invalidIP': 'يرجى إدخال عنوان IP صحيح',
      'invalidPort': 'يرجى إدخال رقم منفذ صحيح (1-65535)',
      'pathMustStartWithSlash': 'يجب أن يبدأ المسار بـ /',
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
  String get damageSeverityDistribution => translate('damageSeverityDistribution');
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