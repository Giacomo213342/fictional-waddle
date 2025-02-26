import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../theme/fonts.dart';
import '../../../../../utils/matrix/sas_localization.dart';

class LocalizedEmojiView extends StatelessWidget {
  const LocalizedEmojiView({
    super.key,
    required this.emoji,
  });

  final SasLocalization emoji;

  @override
  Widget build(BuildContext context) {
    String label;

    final supportedLocales =
        emoji.translatedDescriptions.keys.toList(growable: false);
    final uiLocale = AppLocalizations.of(context).localeName.parseLocale();
    final uiLocaleTranslation = emoji.translatedDescriptions[uiLocale];

    if (uiLocaleTranslation != null) {
      label = uiLocaleTranslation;
    } else {
      final matchedLocale = PlatformDispatcher.instance
          .computePlatformResolvedLocale(supportedLocales);
      final platformLocale = emoji.translatedDescriptions[matchedLocale];
      if (platformLocale != null) {
        label = platformLocale;
      } else {
        // default fallback
        label = emoji.description;
      }
    }
    return SizedBox.square(
      dimension: 96,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Semantics(
            hidden: true,
            child: Text(
              emoji.emoji,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: PolyculeFonts.notoColorEmoji.name,
                    fontSize: 48,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
