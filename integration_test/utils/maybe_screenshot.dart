// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

const nativeScreenshots =
    bool.fromEnvironment('POLYCULE_NATIVE_SCREENSHOTS', defaultValue: false);

extension MaybeScreenshot on IntegrationTestWidgetsFlutterBinding {
  Future<List<int>?> maybeScreenshot(
    String screenshotName, [
    Map<String, Object?>? args,
  ]) async {
    if (!kIsWeb && Platform.isAndroid || Platform.isIOS) {
      if (nativeScreenshots && Platform.isAndroid) {
        print('[android] Grabbing screenshot using screengrep ...');
        final tmp = await getTemporaryDirectory();
        screenshotName = '${tmp.path}/$screenshotName.png';
        await Directory(
          screenshotName.substring(0, screenshotName.lastIndexOf('/')),
        ).create(recursive: true);
        await Process.run('screencap', '-p $screenshotName'.split(' '));

        print('[android] Done.');
      }
      return takeScreenshot(screenshotName, args);
    }
    return null;
  }
}
