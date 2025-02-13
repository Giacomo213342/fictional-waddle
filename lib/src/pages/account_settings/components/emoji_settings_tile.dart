import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../account_settings.dart';
import '../pages/emoji_settings/emoji_settings.dart';

class EmojiSettingsTile extends StatelessWidget {
  const EmojiSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.emoji_emotions),
      title: Text(
        AppLocalizations.of(context).emojiSettings,
      ),
      onTap: () => context.pushMultiClient(
        AccountSettings.makeSettingsUri(
          EmojiSettingsPage.routeName,
        ),
      ),
    );
  }
}
