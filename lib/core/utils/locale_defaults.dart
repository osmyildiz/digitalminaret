import 'dart:ui';

import '../enums/calculation_method.dart';

class LocaleDefaults {
  /// Returns the best matching app locale code for the given platform locale.
  /// Falls back to 'en' if no match is found.
  static String resolveAppLocale(Locale platformLocale) {
    const supported = {
      'en', 'tr', 'ar', 'ur', 'id', 'fa', 'fr',
    };
    final lang = platformLocale.languageCode;
    if (supported.contains(lang)) {
      return lang;
    }
    // Malay speakers can understand Indonesian
    if (lang == 'ms') {
      return 'id';
    }
    // Dari (Pashto region) falls back to Farsi
    if (lang == 'ps' || lang == 'prs') {
      return 'fa';
    }
    return 'en';
  }

  /// Returns the most appropriate calculation method for the given locale.
  static CalculationMethod resolveCalculationMethod(Locale platformLocale) {
    final lang = platformLocale.languageCode;
    final country = platformLocale.countryCode?.toUpperCase() ?? '';

    // Country-specific overrides first (more precise)
    switch (country) {
      case 'TR':
        return CalculationMethod.turkeyDiyanet;
      case 'SA':
      case 'QA':
      case 'BH':
      case 'KW':
      case 'OM':
      case 'YE':
        return CalculationMethod.ummAlQura;
      case 'AE':
        return CalculationMethod.dubai;
      case 'PK':
      case 'IN':
      case 'BD':
      case 'AF':
      case 'NP':
      case 'LK':
        return CalculationMethod.karachi;
      case 'ID':
      case 'MY':
      case 'SG':
      case 'BN':
      case 'TH':
      case 'PH':
      case 'MM':
        return CalculationMethod.singapore;
      case 'IR':
      case 'TJ':
        return CalculationMethod.tehran;
      case 'EG':
      case 'LY':
      case 'SD':
        return CalculationMethod.egyptian;
      case 'US':
      case 'CA':
        return CalculationMethod.isna;
      case 'DZ':
      case 'TN':
      case 'MA':
      case 'SN':
      case 'ML':
      case 'CI':
      case 'GN':
        return CalculationMethod.muslimWorldLeague;
    }

    // Language-based fallback
    switch (lang) {
      case 'tr':
        return CalculationMethod.turkeyDiyanet;
      case 'ar':
        return CalculationMethod.ummAlQura;
      case 'ur':
        return CalculationMethod.karachi;
      case 'id':
      case 'ms':
        return CalculationMethod.singapore;
      case 'fa':
      case 'ps':
      case 'prs':
        return CalculationMethod.tehran;
      case 'fr':
        return CalculationMethod.muslimWorldLeague;
      default:
        return CalculationMethod.isna;
    }
  }
}
