import 'package:flutter/material.dart';

import 'package:emoji_extension/emoji_extension.dart';
import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../utils/matrix/autoplay_animated_content_extension.dart';
import '../../../../utils/matrix/matrix_state.dart';
import 'components/tone_button.dart';

class EmojiSettingsPage extends StatefulWidget {
  const EmojiSettingsPage({super.key});

  static const routeName = 'emojis';

  @override
  State<EmojiSettingsPage> createState() => _EmojiSettingsPageState();
}

class _EmojiSettingsPageState extends MatrixState<EmojiSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).emojiSettings),
      ),
      body: ListView(
        children: [
          StreamBuilder<SyncUpdate>(
            stream: client.onSync.stream
                .where((update) => update.accountData?.isNotEmpty ?? false),
            builder: (context, _) => SwitchListTile.adaptive(
              title: Text(AppLocalizations.of(context).autoplayAnimations),
              value: client.autoplayAnimatedContent ?? true,
              onChanged: client.setAutoplayAnimatedContent,
            ),
          ),
          const Divider(),
          ListTile(
            title: SizedBox(
              height: 64,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  null,
                  ...SkinTone.values,
                ]
                    .map(
                      (tone) => ToneButton(
                        tone: tone,
                        client: client,
                      ),
                    )
                    .toList(),
              ),
            ),
            subtitle: Text(AppLocalizations.of(context).defaultEmojiTone),
          ),
        ],
      ),
    );
  }
}
