import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:integration_test/integration_test.dart';
import 'package:polycule/l10n/generated/app_localizations.dart';
import 'package:polycule/src/pages/room/components/compose/type_ahead_helper.dart';
import 'package:polycule/src/pages/room_list/components/sliding_sync_proxy.dart';
import 'package:polycule/src/polycule.dart';

import '../users.dart';
import '../utils/login.dart';
import '../utils/maybe_screenshot.dart';
import '../utils/wait_for.dart';

void roomFlow({
  required IntegrationTestWidgetsFlutterBinding binding,
  required AppLocalizations l10n,
  required Users user,
}) {
  testWidgets(
    'room',
    (tester) async {
      await tester.pumpWidget(const PolyculeClient());
      await tester.pumpAndSettle();

      await tester.loginBootstrap(
        l10n: l10n,
        user: user,
      );

      {
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(EditableText).last, '/');
        await tester.pump();
        await binding.maybeScreenshot(screenshotName('commands'));
      }

      {
        final name = '< polycule > matrix room';
        await tester.enterText(
          find.byType(EditableText).last,
          '/create $name',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // snack bar
        await Future.delayed(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        await tester.waitFor(
          find.descendant(
            of: find.byType(SlidingSyncProxy),
            matching: find.text(name),
          ),
        );
        await tester.tap(find.text(name));
        await tester.pumpAndSettle();
      }

      {
        await tester.tap(find.byType(TypeAheadField<TypeAheadOption>));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.descendant(
            of: find.byType(TypeAheadField<TypeAheadOption>),
            matching: find.byType(TextField).last,
          ),
          ':plead',
        );
        await tester.pumpAndSettle();
        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pump();
        await binding.maybeScreenshot(screenshotName('emojis'));
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }
    },
    tags: ['screenshot'],
  );
}
