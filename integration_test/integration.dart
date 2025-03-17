import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:matrix/matrix.dart';
import 'package:media_kit/media_kit.dart';
import 'package:polycule/l10n/generated/app_localizations_en.dart';

import 'flows/account_settings.dart';
import 'flows/application_settings.dart';
import 'flows/login.dart';
import 'flows/room.dart';
import 'flows/welcome_screen.dart';
import 'users.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.testTextInput.register();

  group(
    'Integration test',
    () {
      final l10n = AppLocalizationsEn();
      final user = Users.alice;
      setUpAll(() async {
        Logs().level = Level.verbose;

        MediaKit.ensureInitialized();
        JustAudioMediaKit.ensureInitialized();

        if (kProfileMode) {
          await binding.convertFlutterSurfaceToImage();
        }
      });
      welcomeScreenFlow(
        binding: binding,
        l10n: l10n,
      );
      applicationSettingsFlow(
        binding: binding,
        l10n: l10n,
      );
      loginFlow(
        binding: binding,
        l10n: l10n,
        user: user,
      );
      accountSettingsFlow(
        binding: binding,
        l10n: l10n,
        user: user,
      );
      roomFlow(
        binding: binding,
        l10n: l10n,
        user: user,
      );
    },
  );
}
