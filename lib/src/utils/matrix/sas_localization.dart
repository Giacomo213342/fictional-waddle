import 'dart:ui';

import 'package:matrix/encryption/utils/key_verification.dart';

class SasLocalization {
  const SasLocalization({
    required this.number,
    required this.emoji,
    required this.description,
    required this.unicode,
    required this.translatedDescriptions,
  });

  factory SasLocalization.fromJson(Map<String, Object?> json) =>
      SasLocalization(
        number: json['number']! as int,
        emoji: json['emoji']! as String,
        description: json['description']! as String,
        unicode: json['unicode']! as String,
        translatedDescriptions: _mapDescriptions(
          json['translated_descriptions']! as Map<String, Object?>,
        ),
      );

  final int number;
  final String emoji;
  final String description;
  final String unicode;
  final Map<Locale, String> translatedDescriptions;

  static Map<Locale, String> _mapDescriptions(
    Map<String, Object?> descriptions,
  ) {
    final translations = <Locale, String>{};
    descriptions.forEach((k, v) {
      if (v is! String) {
        return;
      }
      translations[k.parseLocale()] = v;
    });
    return translations;
  }
}

extension LocalizedKeyVerificationEmoji on KeyVerificationEmoji {
  SasLocalization localized(List<SasLocalization> localizations) {
    return localizations.singleWhere((l10n) => l10n.number == number);
  }
}

extension ParseLocale on String {
  Locale parseLocale() {
    final parts = split('_');
    final primary = parts[0];
    if (parts.length == 1) {
      return Locale(primary);
    }
    // let's find out whether a country or script is supplied
    final secondary = parts[1];
    // when secondary identifier all uppercase, I assume a country
    if (secondary.toUpperCase() == secondary) {
      return Locale(
        primary,
        secondary,
      );
    } else {
      return Locale.fromSubtags(
        languageCode: primary,
        scriptCode: secondary,
      );
    }
  }
}
