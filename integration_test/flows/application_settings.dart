import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:polycule/l10n/generated/app_localizations.dart';
import 'package:polycule/src/pages/homeserver/homeserver.dart';
import 'package:polycule/src/pages/room_list/room_list_view.dart';
import 'package:polycule/src/polycule.dart';

import '../utils/maybe_screenshot.dart';

void applicationSettingsFlow({
  required IntegrationTestWidgetsFlutterBinding binding,
  required AppLocalizations l10n,
}) {
  testWidgets(
    'Application settings',
    (tester) async {
      await tester.pumpWidget(const PolyculeClient());
      await tester.pumpAndSettle();

      while (!find.byType(RoomListView).tryEvaluate() &&
          !find.byType(HomeserverPage).tryEvaluate()) {
        await tester.pumpAndSettle();
      }

      // mobile UI
      if (find.byTooltip(l10n.clientSwitcher).tryEvaluate()) {
        await tester.tap(find.byTooltip(l10n.clientSwitcher));
        await tester.pumpAndSettle();

        await tester.pump();
        await binding.maybeScreenshot(
          screenshotName('mobile-client-chooser'),
        );

        await tester.tap(find.text(l10n.settings));
        await tester.pumpAndSettle();
      }
      // desktop UI
      else {
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();
      }

      {
        await tester.pump();
        await binding.maybeScreenshot(
          screenshotName('application-settings'),
        );
      }
      {
        await tester.tap(find.text(l10n.appearanceAccessibilitySettings));
        await tester.pumpAndSettle();
        await tester.pump();
        await binding.maybeScreenshot(
          screenshotName('accessibility-settings'),
        );
        await tester.tap(find.byType(BackButton).first);
        await tester.pumpAndSettle();
      }
      {
        await tester.tap(find.text(l10n.pushSettings));
        await tester.pumpAndSettle();
        await tester.pump();
        await binding.maybeScreenshot(
          screenshotName('push-settings'),
        );
        await tester.tap(find.byType(BackButton).first);
        await tester.pumpAndSettle();
      }
      {
        await tester.tap(find.text(l10n.networkSettings));
        await tester.pumpAndSettle();
        await tester.pump();
        await binding.maybeScreenshot(
          screenshotName('network-settings'),
        );
        await tester.tap(find.byType(BackButton).first);
        await tester.pumpAndSettle();
      }
      {
        await tester.tap(find.text(l10n.language));
        await tester.pumpAndSettle();
        await tester.pump();
        await binding.maybeScreenshot(
          screenshotName('language-settings'),
        );
        await tester.tap(find.text(l10n.systemLanguage));
        await tester.pumpAndSettle();
      }
      {
        await tester.tap(find.text(l10n.errorReporting));
        await tester.pumpAndSettle();
        await tester.pump();
        await binding.maybeScreenshot(
          screenshotName('error-reporting'),
        );
        await tester.tap(find.byType(BackButton).first);
        await tester.pumpAndSettle();
      }
    },
    tags: ['screenshot'],
  );
}
