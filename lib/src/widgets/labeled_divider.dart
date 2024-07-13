import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

class LabeledDivider extends Divider {
  const LabeledDivider({super.key, this.label});

  final Widget? label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(child: super.build.call(context)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: label ?? Text(AppLocalizations.of(context).or),
        ),
        Expanded(child: super.build.call(context)),
      ],
    );
  }
}
