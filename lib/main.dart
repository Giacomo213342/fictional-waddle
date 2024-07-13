import 'dart:async';

import 'package:flutter/material.dart';

import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:matrix/matrix.dart';
import 'package:media_kit/media_kit.dart';

import 'src/polycule.dart';

void main(List<String>? args) {
  Logs().level = Level.verbose;
  // used to capture errors in main thread
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      MediaKit.ensureInitialized();
      JustAudioMediaKit.ensureInitialized();
      runApp(const PolyculeClient());
    },
    (error, stack) {
      // TODO: de-obfuscate web stack traces using source maps
      Logs().wtf('Error launching main applications', error, stack);
    },
  );
}
