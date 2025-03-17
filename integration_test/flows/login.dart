import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:polycule/l10n/generated/app_localizations.dart';
import 'package:polycule/src/pages/room_list/room_list_view.dart';
import 'package:polycule/src/polycule.dart';
import 'package:polycule/src/widgets/polycule_highlight_view.dart';

import '../users.dart';
import '../utils/homeserver.dart';
import '../utils/maybe_screenshot.dart';
import '../utils/wait_for.dart';

void loginFlow({
  required IntegrationTestWidgetsFlutterBinding binding,
  required AppLocalizations l10n,
  required Users user,
}) {
  testWidgets(
    'Login',
    (tester) async {
      await tester.pumpWidget(const PolyculeClient());
      await tester.pumpAndSettle();

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

        await tester.pump();
        await binding.maybeScreenshot(screenshotName('login'));
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

          await tester.pump();
          await binding.maybeScreenshot(screenshotName('login-legacy'));

          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();

          // click the button on devices which don't handle the input action
          if (find.text(l10n.submit).tryEvaluate()) {
            await tester.tap(find.text(l10n.submit));
            await tester.pumpAndSettle();
          }
        }

        await tester.waitFor(
          find.byType(RoomListView),
          // SSSS bootstrap
          timeout: const Duration(minutes: 1),
        );

        await tester.pump();
        await binding.maybeScreenshot(screenshotName('room-list'));

        await tester.tap(find.byTooltip(l10n.accountSettings));
        await tester.pumpAndSettle();

        await tester.tap(find.text(l10n.keyBackupAvailable));
        await tester.pumpAndSettle();

        do {
          await tester.pumpAndSettle();
          final result = find.byType(PolyculeHighlightView).evaluate();
          final view = result.single.widget as PolyculeHighlightView;
          ssss = view.input;
        } while (
            ssss == null || ssss == List.generate(12, (_) => 'XXXX').join(' '));

        await tester.tap(find.text(l10n.confirmSSSSKeyStored));
      }
    },
    tags: ['screenshot'],
  );
}
