import 'package:flutter/widgets.dart';

/// Locale-aware string casing.
///
/// Dart's [String.toUpperCase] uses the Unicode default mapping, which
/// is wrong for Turkish and Azeri: it turns dotted "i" into dotless "I"
/// instead of "İ", producing "İKINDI" where "İKİNDİ" is correct.
///
/// This extension fixes the dotted/dotless rule for `tr` and `az`
/// locales and falls back to plain `toUpperCase` for everything else.
extension LocaleStringCasing on String {
  String toLocaleUpperCase(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    return upperCaseForLocale(locale?.languageCode);
  }

  /// Same logic without a BuildContext — useful from layers that don't
  /// have access to one (e.g. providers, services).
  String upperCaseForLocale(String? languageCode) {
    if (languageCode == 'tr' || languageCode == 'az') {
      // Replace lowercase i/ı with their Turkish uppercase counterparts
      // BEFORE toUpperCase so the standard mapping can't undo them.
      return replaceAll('i', 'İ') // İ (LATIN CAPITAL LETTER I WITH DOT ABOVE)
          .replaceAll('ı', 'I')
          .toUpperCase();
    }
    return toUpperCase();
  }
}
