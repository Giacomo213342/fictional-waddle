import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_highlighting/flutter_highlighting.dart';
import 'package:flutter_highlighting/themes/dracula.dart';
import 'package:flutter_highlighting/themes/intellij-light.dart';
import 'package:highlighting/languages/all.dart' as highlight;

import '../theme/fonts.dart';

class PolyculeHighlightView extends StatelessWidget {
  const PolyculeHighlightView(
    this.input, {
    super.key,
    this.language,
  });

  final String input;
  final String? language;

  static const _kInnerPadding = EdgeInsets.fromLTRB(8, 8, 48, 8);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // ensure we only render languages supported by package:highlight
    final languageId =
        highlight.allLanguages.containsKey(language) ? language : null;

    final textStyle = TextStyle(
      color: colorScheme.onTertiaryContainer,
      overflow: TextOverflow.visible,
      fontFamily: PolyculeFonts.notoSansMono.name,
      fontFamilyFallback: [
        PolyculeFonts.notoColorEmoji.name,
        PolyculeFonts.notoSans.name,
      ],
      // prevent inline markdown
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal,
    );
    final codeTheme = Theme.of(context).brightness == Brightness.dark
        ? draculaTheme
        : intellijLightTheme;

    final background =
        codeTheme['root']?.backgroundColor ?? colorScheme.tertiaryContainer;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: colorScheme.primary,
          ),
        ),
        color: background,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        child: SelectionArea(
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: languageId == null
                      ? Padding(
                          padding: _kInnerPadding,
                          child: Text(
                            input,
                            style: textStyle,
                          ),
                        )
                      : HighlightView(
                          input,
                          languageId: language,
                          textStyle: textStyle,
                          theme: codeTheme,
                          padding: _kInnerPadding,
                        ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  tooltip: MaterialLocalizations.of(context).copyButtonLabel,
                  onPressed: () => Clipboard.setData(
                    ClipboardData(text: input),
                  ),
                  icon: const Icon(Icons.copy),
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
