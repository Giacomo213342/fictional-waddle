import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:polycule/l10n/generated/app_localizations.dart';
import 'package:polycule/src/polycule.dart';

import '../utils/maybe_screenshot.dart';
import '../utils/wait_for.dart';

void welcomeScreenFlow({
  required IntegrationTestWidgetsFlutterBinding binding,
  required AppLocalizations l10n,
}) {
  testWidgets(
    'Welcome screen',
    (tester) async {
      await tester.pumpWidget(const PolyculeClient());
      await tester.pumpAndSettle();

      // blinking cursor
      await tester.waitFor(
        find.text(l10n.homeserverHeadline),
        skipPumpAndSettle: true,
      );
      {
        await tester.pump();
        await binding.maybeScreenshot(screenshotName('homeserver'));
      }

      {
        await tester.tap(find.text(l10n.about));
        await tester.pumpAndSettle();
        await tester.pump();
        await binding.maybeScreenshot(
          screenshotName('about-dialog'),
        );
        await tester.tap(find.text(l10n.close));
        await tester.pumpAndSettle();
      }
    },
    tags: ['screenshot'],
  );
}
