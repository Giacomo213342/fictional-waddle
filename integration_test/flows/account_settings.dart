import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:polycule/l10n/generated/app_localizations.dart';
import 'package:polycule/src/polycule.dart';

import '../users.dart';
import '../utils/login.dart';
import '../utils/maybe_screenshot.dart';

void accountSettingsFlow({
  required IntegrationTestWidgetsFlutterBinding binding,
  required AppLocalizations l10n,
  required Users user,
}) {
  testWidgets(
    'Account settings',
    (tester) async {
      await tester.pumpWidget(const PolyculeClient());
      await tester.pumpAndSettle();

      await tester.loginBootstrap(
        l10n: l10n,
        user: user,
      );

      {
        await tester.tap(find.byTooltip(l10n.accountSettings));
        await tester.pumpAndSettle();
        await tester.pump();
        await binding.maybeScreenshot(screenshotName('account'));
      }

      {
        await tester.tap(find.text(l10n.emojiSettings));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip(l10n.mediumSkin));
        await tester.pumpAndSettle();

        // wait for lottie to load
        await Future.delayed(const Duration(milliseconds: 500));

        await tester.pump();
        await binding.maybeScreenshot(
          screenshotName('emoji-settings'),
        );
        await tester.tap(find.byType(BackButton).first);
        await tester.pumpAndSettle();
      }

      {
        await tester.tap(find.text(l10n.manageSessions));
        await tester.pumpAndSettle();
        await tester.pump();
        await binding.maybeScreenshot(
          screenshotName('manage-sessions'),
        );
        await tester.tap(find.byType(BackButton).first);
        await tester.pumpAndSettle();
      }
    },
    tags: ['screenshot'],
  );
}
