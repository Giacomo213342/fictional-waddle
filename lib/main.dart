import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:matrix/matrix.dart';
import 'package:media_kit/media_kit.dart';

import 'src/polycule.dart';
import 'src/utils/error_logger.dart';
import 'src/utils/matrix/client_util.dart';
import 'src/utils/matrix/push_handler.dart';
import 'src/utils/single_tab/single_tab.dart';

@pragma('vm:entry-point')
void main([List<String>? args]) {
  FlutterError.onError = (details) {
    ErrorLogger().captureStackTrace(details.exception, details.stack, false);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorLogger().captureStackTrace(error, stack, false);
    return true;
  };
  // used to capture errors in main thread
  runZonedGuarded(
    () async {
      Logs().level = Level.verbose;
      Logs().v('Called main() with arguments: $args');

      WidgetsFlutterBinding.ensureInitialized();
      await ClientUtil.initVodozemac();

      if (args?.contains('--unifiedpush-bg') ?? false) {
        return pushEntrypoint();
      }

      MediaKit.ensureInitialized();
      JustAudioMediaKit.ensureInitialized();

      if (!await ensureSingleTab()) {
        return;
      }
      runApp(const PolyculeClient());
    },
    (e, s) {
      ErrorLogger().captureStackTrace(e, s);
    },
  );
}
