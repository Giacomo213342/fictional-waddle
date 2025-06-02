import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

import 'package:polycule/src/utils/dart_environment.dart';
import 'screenshot/android.dart';

final formFactor = Platform.environment['FORMFACTOR'] ?? 'mobile';
const nativeScreenshots = DartEnvironment.nativeScreenshots;

Future<void> main() async {
  final driver = await FlutterDriver.connect();
  await integrationDriver(
    driver: driver,
    onScreenshot: (screenshotName, screenshotBytes, [args]) async {
      if (nativeScreenshots && screenshotName.contains('android')) {
        screenshotBytes = await screenshotAndroid(screenshotName);
        // remove the prefix
        screenshotName = screenshotName.replaceAll(
          '/data/user/0/business.braid.polycule/cache/',
          '',
        );
      }
      // ensure we will neither duplicate .png nor forget it
      if (!screenshotName.endsWith('.png')) {
        screenshotName += '.png';
      }
      final path = screenshotName.split('/');
      path.insert(1, formFactor);
      final image = await File('assets/screenshots/${path.join('/')}')
          .create(recursive: true);
      await image.writeAsBytes(screenshotBytes);
      return true;
    },
    writeResponseOnFailure: true,
  );
}
