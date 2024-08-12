import 'package:flutter/material.dart';

import 'package:url_launcher/link.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../widgets/polycule_overflow_bar.dart';

class UnifiedPushUnavailable extends StatelessWidget {
  const UnifiedPushUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.notifications_off),
          title: Text(
            AppLocalizations.of(context).unifiedPushUnavailable,
          ),
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context).pushInformationPolycule,
          ),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context).unifiedPushAbout),
        ),
        PolyculeOverflowBar(
          children: [
            Link(
              uri: Uri.parse(
                AppLocalizations.of(context).unifiedPushLink,
              ),
              builder: (context, followLink) {
                return TextButton(
                  onPressed: followLink,
                  child: Text(
                    AppLocalizations.of(context).setupUnifiedPush,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
