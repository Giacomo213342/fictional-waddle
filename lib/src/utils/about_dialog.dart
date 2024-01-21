import 'package:flutter/material.dart';

import 'package:url_launcher/link.dart';

import '../../l10n/generated/app_localizations.dart';
import 'version.dart';

void showInfoDialog(BuildContext context) => showAboutDialog(
      context: context,
      applicationVersion: Version.version,
      applicationIcon: Image.asset(
        'assets/logo/logo-circle.png',
        width: 64,
        height: 64,
      ),
      applicationLegalese: '${AppLocalizations.of(context).appSlogan}\n\n'
          '${AppLocalizations.of(context).author(Version.author)}',
      children: [
        Link(
          uri: Uri.parse(Version.gitlabRepoBase),
          builder: (context, followLink) {
            return OutlinedButton.icon(
              onPressed: followLink,
              icon: const Icon(Icons.public),
              label: Text(AppLocalizations.of(context).repoLabel),
            );
          },
        ),
        Link(
          uri: Version.isStable
              ? Uri.parse(Version.stableChangeLog)
              : Uri.parse(Version.commitList),
          builder: (context, followLink) {
            return OutlinedButton.icon(
              onPressed: followLink,
              icon: const Icon(Icons.list_alt),
              label: Text(AppLocalizations.of(context).releaseNotes),
            );
          },
        ),
        Link(
          uri: Uri.parse(Version.donationLink),
          builder: (context, followLink) {
            return OutlinedButton.icon(
              onPressed: followLink,
              icon: const Icon(Icons.coffee),
              label: Text(AppLocalizations.of(context).buyMeACoffee),
            );
          },
        ),
      ]
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: e,
            ),
          )
          .toList(),
    );
