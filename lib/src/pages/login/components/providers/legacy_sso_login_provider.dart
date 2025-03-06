import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../utils/matrix/legacy_idp_extension.dart';
import '../legacy_idp_button.dart';

class LegacySSOProviderScope extends InheritedWidget {
  const LegacySSOProviderScope({
    super.key,
    required super.child,
    required this.ssoFlow,
  });

  factory LegacySSOProviderScope.of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LegacySSOProviderScope>()!;

  final LoginFlow ssoFlow;

  @override
  bool updateShouldNotify(covariant LegacySSOProviderScope oldWidget) =>
      ssoFlow != oldWidget.ssoFlow;
}

class LegacySSOLoginProvider extends StatefulWidget {
  const LegacySSOLoginProvider({super.key});

  @override
  State<LegacySSOLoginProvider> createState() => _LegacySSOLoginProviderState();
}

class _LegacySSOLoginProviderState extends State<LegacySSOLoginProvider> {
  @override
  Widget build(BuildContext context) {
    final flow = LegacySSOProviderScope.of(context).ssoFlow;
    final idps = flow.legacyIdps;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        padding: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(width: 4, color: Theme.of(context).focusColor),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).loginLegacySso,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: idps
                    .map((idp) => LegacyIdpButton(idp: idp))
                    .toList(growable: false),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
