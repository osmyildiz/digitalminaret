import 'dart:ui';

class SupportedLocaleInfo {
  const SupportedLocaleInfo({
    required this.locale,
    required this.nativeName,
    required this.englishName,
  });

  final Locale locale;
  final String nativeName;
  final String englishName;
}

class SupportedLocales {
  static const List<SupportedLocaleInfo> all = [
    SupportedLocaleInfo(
      locale: Locale('en'),
      nativeName: 'English',
      englishName: 'English',
    ),
    SupportedLocaleInfo(
      locale: Locale('tr'),
      nativeName: 'Türkçe',
      englishName: 'Turkish',
    ),
    SupportedLocaleInfo(
      locale: Locale('ar'),
      nativeName: 'العربية',
      englishName: 'Arabic',
    ),
    SupportedLocaleInfo(
      locale: Locale('ur'),
      nativeName: 'اردو',
      englishName: 'Urdu',
    ),
    SupportedLocaleInfo(
      locale: Locale('id'),
      nativeName: 'Indonesia',
      englishName: 'Indonesian',
    ),
    SupportedLocaleInfo(
      locale: Locale('fr'),
      nativeName: 'Français',
      englishName: 'French',
    ),
    SupportedLocaleInfo(
      locale: Locale('fa'),
      nativeName: 'فارسی',
      englishName: 'Persian',
    ),
  ];
}
