import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/l10n/generated/app_localizations.dart';
import 'package:polycule/src/pages/homeserver/homeserver.dart';
import 'package:polycule/src/pages/room_list/room_list_view.dart';
import 'package:polycule/src/pages/ssss_bootstrap/components/open_existing_ssss/open_existing_ssss.dart';

import '../users.dart';
import 'homeserver.dart';
import 'wait_for.dart';

extension PolyculeLoginExtension on WidgetTester {
  Future<void> loginBootstrap({
    required AppLocalizations l10n,
    required Users user,
  }) async {
    final tester = this;

    while (!find.byType(RoomListView).tryEvaluate() &&
        !find.byType(HomeserverPage).tryEvaluate()) {
      await tester.pumpAndSettle();
    }

    // easy when we're already logged in
    if (find.byType(RoomListView).tryEvaluate()) {
      return;
    }

    // blinking cursor
    await tester.waitFor(
      find.text(l10n.homeserverHeadline),
      skipPumpAndSettle: true,
    );

    {
      await tester.enterText(find.byType(EditableText), homeserver);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      // click the icon on devices which don't handle the input action
      if (find.byIcon(Icons.rocket_launch).tryEvaluate()) {
        await tester.tap(find.byIcon(Icons.rocket_launch));
        await tester.pumpAndSettle();
      }
    }

    // login screen

    {
      await tester.waitFor(
        find.text(l10n.welcomeToHomeserver(Uri.parse(homeserver).host)),
      );

      // legacy login
      if (find.text(l10n.username).tryEvaluate()) {
        await tester.tap(find.text(l10n.username));
        await tester.pumpAndSettle();
      }
    }

    {
      // legacy login
      if (find.text(l10n.username).tryEvaluate()) {
        await tester.enterText(
          find.byType(EditableText).first,
          user.username,
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(EditableText).last,
          user.password,
        );

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // click the button on devices which don't handle the input action
        if (find.text(l10n.submit).tryEvaluate()) {
          await tester.tap(find.text(l10n.submit));
          await tester.pumpAndSettle();
        }
      }

      await tester.waitFor(
        find.byType(OpenExistingSsssWidget),
        // SSSS bootstrap
        timeout: const Duration(minutes: 1),
      );

      final s = ssss;
      if (s != null) {
        await tester.enterText(
          find.byType(EditableText).last,
          s,
        );
        await tester.tap(find.text(l10n.verifyWithPassphrase));
        await tester.pumpAndSettle();
      } else {
        await tester.tap(find.text(l10n.wipeAccount));
        await tester.pumpAndSettle();

        await tester.tap(find.text(l10n.deleteAll));
        await tester.pumpAndSettle();
      }

      await tester.waitFor(
        find.byType(RoomListView),
        // SSSS bootstrap
        timeout: const Duration(minutes: 1),
      );
    }
  }
}
