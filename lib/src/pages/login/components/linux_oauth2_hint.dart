import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/polycule_highlight_view.dart';

class LinuxOAuth2Hint extends StatelessWidget {
  const LinuxOAuth2Hint({super.key, required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) => AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: SizedBox(
          height: expanded ? null : 0,
          child: ClipRect(
            clipBehavior: Clip.hardEdge,
            child: OverflowBox(
              fit: OverflowBoxFit.deferToChild,
              child: SelectionArea(
                child: ListTile(
                  leading: const Icon(Icons.developer_mode),
                  title: Text(
                    AppLocalizations.of(context).linuxOidcWorkaround,
                  ),
                  subtitle: PolyculeHighlightView(
                    AppLocalizations.of(context).linuxOidcWorkaroundSnippet,
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
          ),
        ),
      );
}
