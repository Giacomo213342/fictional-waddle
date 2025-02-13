import 'package:flutter/material.dart';

import 'package:dart_animated_emoji/dart_animated_emoji.dart';
import 'package:emoji_extension/emoji_extension.dart';
import 'package:lottie/lottie.dart';
import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../utils/matrix/default_emoji_tone.dart';
import '../../../../../widgets/matrix/scopes/client_scope.dart';

class ToneButton extends StatelessWidget {
  ToneButton({super.key, this.tone}) {
    final tone = this.tone;
    _glyph = tone == null
        ? _baseGlyph
        : Emojis.bySkinTone(tone)
            .firstWhere(
              (emoji) => emoji.name.contains(_baseEmojiName),
            )
            .value;
  }

  final SkinTone? tone;
  late final String _glyph;

  static const _baseGlyph = '\u{1f44b}';
  static const _baseEmojiName = 'Waving Hand';
  static const _size = 20.0;

  @override
  Widget build(BuildContext context) {
    final tone = this.tone;
    final client = ClientScope.of(context).client;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<SyncUpdate>(
        stream: client.onSync.stream
            .where((update) => update.accountData?.isNotEmpty ?? false),
        builder: (context, _) => IconButton(
          isSelected: client.defaultEmojiTone == tone,
          selectedIcon: SizedBox.square(
            dimension: _size * 1.5,
            child: AspectRatio(
              aspectRatio: 1,
              child: Lottie.asset(
                AnimatedEmoji.flutterNotoDotLottieAsset,
                decoder: (bytes) => LottieComposition.decodeZip(
                  bytes,
                  filePicker:
                      AnimatedEmoji.fromGlyph(_glyph)?.archiveFilePicker,
                ),
                width: _size,
                height: _size,
              ),
            ),
          ),
          onPressed: () => client.setDefaultEmojiTone(tone),
          tooltip: _tooltip(context),
          icon: AspectRatio(
            aspectRatio: 1,
            child: SizedBox.square(
              dimension: _size * 1.5,
              child: Center(
                child: Text(
                  _glyph,
                  style: const TextStyle(fontSize: _size),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _tooltip(BuildContext context) => switch (tone) {
        null => AppLocalizations.of(context).yellowSkin,
        SkinTone.light => AppLocalizations.of(context).paleSkin,
        SkinTone.mediumLight => AppLocalizations.of(context).demiPaleSkin,
        SkinTone.medium => AppLocalizations.of(context).mediumSkin,
        SkinTone.mediumDark => AppLocalizations.of(context).brownSkin,
        SkinTone.dark => AppLocalizations.of(context).blackSkin,
      };
}
