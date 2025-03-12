import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:matrix/matrix.dart';
import 'package:media_kit/media_kit.dart';
import 'package:polycule/l10n/generated/app_localizations_en.dart';
import 'package:polycule/src/polycule.dart';
import 'package:polycule/src/widgets/matrix/client_manager/components/client_back_button.dart';

import 'utils/maybe_screenshot.dart';
import 'utils/wait_for.dart';

String _twoCharString(int index) {
  final full = '0$index';
  return full.substring(full.length - 2);
}

int index = 0;

String screenshotName(String name) {
  index++;
  return '${Platform.operatingSystem.toLowerCase()}/'
      '${PlatformDispatcher.instance.platformBrightness.name}/'
      '${_twoCharString(index)}-'
      '$name';
}

void main() {
  final homeserver = Platform.environment['HOMESERVER'] ??
      const String.fromEnvironment(
        'HOMESERVER',
        defaultValue: 'http://homeserver',
      );

  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.testTextInput.register();

  group(
    'Integration test',
    () {
      final l10n = AppLocalizationsEn();
      setUpAll(() async {
        Logs().level = Level.verbose;

        MediaKit.ensureInitialized();
        JustAudioMediaKit.ensureInitialized();

        await binding.convertFlutterSurfaceToImage();
      });
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
            await tester.tap(find.text(l10n.discoverHomeservers));
            await tester.pumpAndSettle();
            await tester.pump();
            await binding.maybeScreenshot(
              screenshotName('homeserver-recommendations'),
            );
          }

          {
            await tester.enterText(find.byType(EditableText), homeserver);
            await tester.testTextInput.receiveAction(TextInputAction.done);
            await tester.pumpAndSettle();
            await tester.tap(find.byTooltip(l10n.connect).first);
            await tester.pumpAndSettle();
          }

          // login screen

          {
            await tester.pump();
            await binding.maybeScreenshot(screenshotName('login'));

            await tester.tap(find.byType(ClientBackButton));
            await tester.pumpAndSettle();
          }

          // wait for any SnackBar to disappear
          while (find.byType(SnackBar).tryEvaluate()) {
            await tester.tap(
              find.descendant(
                of: find.byType(ScaffoldMessenger).last,
                matching: find.byTooltip(l10n.close).last,
              ),
            );
            await tester.pumpAndSettle();
          }

          // back on home screen

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
      testWidgets(
        'Login screen',
        (tester) async {
          await tester.pumpWidget(const PolyculeClient());
          await tester.pumpAndSettle();

          // blinking cursor
          await tester.waitFor(
            find.text(l10n.homeserverHeadline),
            skipPumpAndSettle: true,
          );
          await tester.pumpAndSettle();

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
    },
  );
}
