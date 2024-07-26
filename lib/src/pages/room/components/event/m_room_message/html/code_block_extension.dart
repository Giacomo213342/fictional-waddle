import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_highlighting/flutter_highlighting.dart';
import 'package:flutter_highlighting/themes/dracula.dart';
import 'package:flutter_highlighting/themes/intellij-light.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../../../theme/fonts.dart';

const _kInnerPadding = EdgeInsets.fromLTRB(8, 8, 48, 8);

final _languageRegex = RegExp(r'^language-(\w+)$');

class CodeBlockExtension extends HtmlExtension {
  @override
  Set<String> get supportedTags => {'pre'};

  @override
  bool matches(ExtensionContext context) {
    if (!supportedTags.contains(context.elementName)) {
      return false;
    }

    // only match `pre` tags containing code blocks - ny other one is handled
    // by the HTML renderer itself
    return (context.styledElement?.children.singleOrNull?.name == 'code');
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final colorScheme = Theme.of(context.buildContext!).colorScheme;
    final element = context.styledElement!.element!;

    final classes = element.children.singleOrNull?.classes;

    final language = classes
        ?.map((c) => _languageRegex.firstMatch(c))
        .map((match) => match?.group(1))
        .whereType<String>()
        .singleOrNull;

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
    final codeTheme =
        Theme.of(context.buildContext!).brightness == Brightness.dark
            ? draculaTheme
            : intellijLightTheme;

    final background = language == null
        ? colorScheme.tertiaryContainer
        : codeTheme['root']?.backgroundColor ?? colorScheme.tertiaryContainer;

    final text = element.text.trimRight();

    return WidgetSpan(
      child: DecoratedBox(
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
                    child: language == null
                        ? Padding(
                            padding: _kInnerPadding,
                            child: Text(
                              text,
                              style: textStyle,
                            ),
                          )
                        : HighlightView(
                            text,
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
                    tooltip: MaterialLocalizations.of(context.buildContext!)
                        .copyButtonLabel,
                    onPressed: () => Clipboard.setData(
                      ClipboardData(text: element.text),
                    ),
                    icon: const Icon(Icons.copy),
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
