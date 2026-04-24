import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  AppLocalizations — all UI strings in EN / FR / AR
//  Usage: AppLocalizations.of(context).title
// ═══════════════════════════════════════════════════════════════════════════
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const delegate = _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('ar'),
  ];

  // ── Lookup table ──────────────────────────────────────────────────────────
  static const Map<String, Map<String, String>> _strings = {
    // ── App global
    'appName':              {'en': 'SmartCampus', 'fr': 'SmartCampus', 'ar': 'سمارت كامبس'},

    // ── Bottom nav
    'navHome':              {'en': 'Home',        'fr': 'Accueil',    'ar': 'الرئيسية'},
    'navNews':              {'en': 'News',         'fr': 'Actualités', 'ar': 'الأخبار'},
    'navEvents':            {'en': 'Events',       'fr': 'Événements', 'ar': 'الأحداث'},
    'navProfile':           {'en': 'Profile',      'fr': 'Profil',     'ar': 'الملف الشخصي'},

    // ── Home page
    'goodMorning':          {'en': 'Good morning,', 'fr': 'Bonjour,',   'ar': 'صباح الخير،'},
    'todaySchedule':        {'en': "Today's Schedule", 'fr': "Emploi du temps", 'ar': 'جدول اليوم'},
    'campusServices':       {'en': 'Campus Services', 'fr': 'Services campus', 'ar': 'خدمات الحرم'},
    'upNext':               {'en': 'UP NEXT',     'fr': 'PROCHAIN',   'ar': 'التالي'},
    'diningHall':           {'en': 'Dining Hall\nMenus', 'fr': 'Menus\nResto U', 'ar': 'قاعة\nالطعام'},
    'libraryBooking':       {'en': 'Library\nBooking', 'fr': 'Réservation\nBiblio', 'ar': 'حجز\nالمكتبة'},
    'campusShuttle':        {'en': 'Campus\nShuttle', 'fr': 'Navette\nCampus', 'ar': 'حافلة\nالحرم'},
    'studentSupport':       {'en': 'Student\nSupport', 'fr': 'Support\nÉtudiant', 'ar': 'دعم\nالطلاب'},
    'viewEnrollmentGuide':  {'en': 'View Enrollment Guide', 'fr': 'Guide d\'inscription', 'ar': 'دليل التسجيل'},
    'academicMilestone':    {'en': 'ACADEMIC MILESTONE', 'fr': 'ÉTAPE ACADÉMIQUE', 'ar': 'إنجاز أكاديمي'},
    'offlineModeActive':    {'en': 'Offline Mode Active', 'fr': 'Mode hors ligne', 'ar': 'وضع غير متصل'},
    'offlineModeDesc':      {'en': 'Displaying cached data from your last sync.', 'fr': 'Données en cache depuis la dernière synchro.', 'ar': 'عرض البيانات المحفوظة من المزامنة الأخيرة.'},
    'retry':                {'en': 'RETRY',        'fr': 'RÉESSAYER',  'ar': 'إعادة'},

    // ── News / Announcements
    'campusBulletin':       {'en': 'CAMPUS BULLETIN', 'fr': 'BULLETIN CAMPUS', 'ar': 'نشرة الحرم'},
    'whatsHappening':       {'en': "What's happening", 'fr': "Ce qui se passe", 'ar': 'ما يحدث'},
    'onCampus':             {'en': 'on campus.',   'fr': 'sur le campus.', 'ar': 'في الحرم.'},
    'syncingFeed':          {'en': 'Syncing feed...', 'fr': 'Synchronisation...', 'ar': 'جارٍ المزامنة...'},
    'connectionLost':       {'en': 'Connection Lost', 'fr': 'Connexion perdue', 'ar': 'انقطع الاتصال'},
    'connectionLostDesc':   {'en': "We couldn't reach the campus\nnews server.", 'fr': "Impossible d'atteindre\nle serveur d'actualités.", 'ar': 'تعذّر الوصول إلى\nخادم الأخبار.'},
    'retryBtn':             {'en': 'Retry',        'fr': 'Réessayer',  'ar': 'إعادة المحاولة'},
    'readProtocol':         {'en': 'Read Protocol', 'fr': 'Lire le protocole', 'ar': 'اقرأ البروتوكول'},
    'weeklyScholar':        {'en': 'The Weekly Scholar', 'fr': 'Le Savant Hebdo', 'ar': 'المنبر الأسبوعي'},
    'weeklyScholarDesc':    {'en': 'Subscribe to get the curated campus digest in your inbox every Monday.', 'fr': 'Abonnez-vous pour recevoir la revue campus chaque lundi.', 'ar': 'اشترك للحصول على ملخص الحرم كل يوم اثنين.'},
    'emailHint':            {'en': 'Email',        'fr': 'E-mail',     'ar': 'البريد الإلكتروني'},
    'academic':             {'en': 'ACADEMIC',     'fr': 'ACADÉMIQUE', 'ar': 'أكاديمي'},
    'event':                {'en': 'EVENT',        'fr': 'ÉVÉNEMENT',  'ar': 'حدث'},
    'today':                {'en': 'Today',        'fr': "Aujourd'hui", 'ar': 'اليوم'},
    'daysLeft':             {'en': 'Days Left',    'fr': 'Jours restants', 'ar': 'أيام متبقية'},
    '7daysLeft':            {'en': '7 Days Left',  'fr': '7 Jours restants', 'ar': '7 أيام متبقية'},

    // ── Profile / Settings page
    'profileRole':          {'en': 'Graduate School of Design', 'fr': 'École Supérieure de Design', 'ar': 'كلية الدراسات العليا للتصميم'},
    'deansList':            {'en': "DEAN'S LIST",  'fr': 'MENTION HONNEUR', 'ar': 'قائمة العميد'},
    'juniorScholar':        {'en': 'JUNIOR SCHOLAR', 'fr': 'JEUNE CHERCHEUR', 'ar': 'باحث ناشئ'},
    'preferences':          {'en': 'Preferences', 'fr': 'Préférences', 'ar': 'التفضيلات'},
    'darkTheme':            {'en': 'Dark Theme',  'fr': 'Thème sombre', 'ar': 'المظهر الداكن'},
    'darkThemeDesc':        {'en': 'Switch to high-contrast mode', 'fr': 'Passer en mode contrasté', 'ar': 'التبديل إلى الوضع عالي التباين'},
    'notifications':        {'en': 'Notifications', 'fr': 'Notifications', 'ar': 'الإشعارات'},
    'notificationsDesc':    {'en': 'Real-time campus alerts', 'fr': 'Alertes campus en temps réel', 'ar': 'تنبيهات الحرم الفورية'},
    'cloudStorage':         {'en': 'Cloud Storage', 'fr': 'Stockage Cloud', 'ar': 'التخزين السحابي'},
    'ofGbUsed':             {'en': 'OF 15 GB USED', 'fr': 'SUR 15 GO UTILISÉS', 'ar': 'من 15 جيجابايت مستخدمة'},
    'syncedCloud':          {'en': 'SYNCHRONIZED WITH ACADEMIC CLOUD', 'fr': 'SYNCHRONISÉ AVEC LE CLOUD', 'ar': 'متزامن مع السحابة الأكاديمية'},
    'language':             {'en': 'Language',    'fr': 'Langue',     'ar': 'اللغة'},
    'appLanguage':          {'en': 'App language', 'fr': 'Langue de l\'app', 'ar': 'لغة التطبيق'},
    'account':              {'en': 'Account',     'fr': 'Compte',     'ar': 'الحساب'},
    'changePassword':       {'en': 'Change Password', 'fr': 'Changer le mot de passe', 'ar': 'تغيير كلمة المرور'},
    'signOut':              {'en': 'Sign Out',    'fr': 'Déconnexion', 'ar': 'تسجيل الخروج'},
    'signOutConfirmTitle':  {'en': 'Sign Out',    'fr': 'Déconnexion', 'ar': 'تسجيل الخروج'},
    'signOutConfirmBody':   {'en': 'Are you sure you want to sign out of SmartCampus?', 'fr': 'Voulez-vous vraiment vous déconnecter de SmartCampus ?', 'ar': 'هل أنت متأكد أنك تريد تسجيل الخروج من سمارت كامبس؟'},
    'cancel':               {'en': 'Cancel',      'fr': 'Annuler',    'ar': 'إلغاء'},
    'version':              {'en': 'SmartCampus v1.0.0', 'fr': 'SmartCampus v1.0.0', 'ar': 'سمارت كامبس v1.0.0'},

    // ── Language names (shown in selector)
    'langEnglish':          {'en': 'English',     'fr': 'Anglais',    'ar': 'الإنجليزية'},
    'langFrench':           {'en': 'French',      'fr': 'Français',   'ar': 'الفرنسية'},
    'langArabic':           {'en': 'Arabic',      'fr': 'Arabe',      'ar': 'العربية'},
  };

  String _t(String key) {
    final lang = locale.languageCode;
    return _strings[key]?[lang] ?? _strings[key]?['en'] ?? key;
  }

  // ── Public getters ────────────────────────────────────────────────────────
  String get appName              => _t('appName');

  // Nav
  String get navHome              => _t('navHome');
  String get navNews              => _t('navNews');
  String get navEvents            => _t('navEvents');
  String get navProfile           => _t('navProfile');

  // Home
  String get goodMorning          => _t('goodMorning');
  String get todaySchedule        => _t('todaySchedule');
  String get campusServices       => _t('campusServices');
  String get upNext               => _t('upNext');
  String get diningHall           => _t('diningHall');
  String get libraryBooking       => _t('libraryBooking');
  String get campusShuttle        => _t('campusShuttle');
  String get studentSupport       => _t('studentSupport');
  String get viewEnrollmentGuide  => _t('viewEnrollmentGuide');
  String get academicMilestone    => _t('academicMilestone');
  String get offlineModeActive    => _t('offlineModeActive');
  String get offlineModeDesc      => _t('offlineModeDesc');
  String get retry                => _t('retry');

  // News
  String get campusBulletin       => _t('campusBulletin');
  String get whatsHappening       => _t('whatsHappening');
  String get onCampus             => _t('onCampus');
  String get syncingFeed          => _t('syncingFeed');
  String get connectionLost       => _t('connectionLost');
  String get connectionLostDesc   => _t('connectionLostDesc');
  String get retryBtn             => _t('retryBtn');
  String get readProtocol         => _t('readProtocol');
  String get weeklyScholar        => _t('weeklyScholar');
  String get weeklyScholarDesc    => _t('weeklyScholarDesc');
  String get emailHint            => _t('emailHint');
  String get academic             => _t('academic');
  String get event                => _t('event');
  String get today                => _t('today');
  String get sevenDaysLeft        => _t('7daysLeft');

  // Profile / Settings
  String get profileRole          => _t('profileRole');
  String get deansList            => _t('deansList');
  String get juniorScholar        => _t('juniorScholar');
  String get preferences          => _t('preferences');
  String get darkTheme            => _t('darkTheme');
  String get darkThemeDesc        => _t('darkThemeDesc');
  String get notifications        => _t('notifications');
  String get notificationsDesc    => _t('notificationsDesc');
  String get cloudStorage         => _t('cloudStorage');
  String get ofGbUsed             => _t('ofGbUsed');
  String get syncedCloud          => _t('syncedCloud');
  String get language             => _t('language');
  String get appLanguage          => _t('appLanguage');
  String get account              => _t('account');
  String get changePassword       => _t('changePassword');
  String get signOut              => _t('signOut');
  String get signOutConfirmTitle  => _t('signOutConfirmTitle');
  String get signOutConfirmBody   => _t('signOutConfirmBody');
  String get cancel               => _t('cancel');
  String get version              => _t('version');
  String get langEnglish          => _t('langEnglish');
  String get langFrench           => _t('langFrench');
  String get langArabic           => _t('langArabic');

  // ── RTL helper ────────────────────────────────────────────────────────────
  bool get isRtl => locale.languageCode == 'ar';
  TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Delegate
// ─────────────────────────────────────────────────────────────────────────────
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}