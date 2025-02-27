import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../utils/matrix/sas_localization.dart';
import '../../../../ascii_progress_indicator.dart';
import '../../../scopes/sas_scope.dart';
import 'localized_emoji_view.dart';

class CompareSasEmoji extends StatelessWidget {
  const CompareSasEmoji({
    super.key,
  });

  static const sasEmojiAsset = 'assets/matrix/sas-emoji.json';

  @override
  Widget build(BuildContext context) {
    final verification = SasScope.of(context).verification;
    return FutureBuilder<String>(
      future: DefaultAssetBundle.of(context).loadString(sasEmojiAsset),
      builder: (context, snapshot) {
        final asset = snapshot.data;
        if (asset == null) {
          return const Center(
            child: AsciiProgressIndicator(),
          );
        }
        final json = List<Map<String, Object?>>.from(jsonDecode(asset));
        final localizations = json
            .map((map) => SasLocalization.fromJson(map))
            .toList(growable: false);

        final sasEmojis = verification.sasEmojis;

        return Wrap(
          alignment: WrapAlignment.spaceEvenly,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          runAlignment: WrapAlignment.spaceEvenly,
          children: sasEmojis
              .map(
                (emoji) => LocalizedEmojiView(
                  emoji: emoji.localized(localizations),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}
