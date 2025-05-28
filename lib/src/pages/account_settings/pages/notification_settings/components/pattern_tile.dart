import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../theme/fonts.dart';

class PatternTile extends StatelessWidget {
  const PatternTile({super.key, required this.pattern});

  final String pattern;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.pattern),
      title: DefaultTextStyle(
        style: TextStyle(fontFamily: PolyculeFonts.notoSansMono.name),
        child: Text(pattern),
      ),
      subtitle: Text(AppLocalizations.of(context).eventContentMatches),
    );
  }
}
