import 'package:flutter/foundation.dart';

final class DartEnvironment {
  static const appOrigin = String.fromEnvironment(
    'POLYCULE_APP_ORIGIN',
    defaultValue: 'https://polycule.im/web/',
  );

  static const isStable = bool.fromEnvironment(
    'POLYCULE_IS_STABLE',
    defaultValue: false,
  );

  static const polyculeVersion = String.fromEnvironment(
    'POLYCULE_VERSION',
    defaultValue: 'debug',
  );

  static const isIntegrationTest =
      bool.fromEnvironment('POLYCULE_IS_INTEGRATION_TEST');

  @visibleForTesting
  static const homeserver = String.fromEnvironment(
    'HOMESERVER',
    defaultValue: 'http://homeserver',
  );

  @visibleForTesting
  static const matrixRegistrationToken = String.fromEnvironment(
    'MATRIX_REGISTRATION_TOKEN',
    defaultValue: 'SomeSecret',
  );

  @visibleForTesting
  static const nativeScreenshots =
      bool.fromEnvironment('POLYCULE_NATIVE_SCREENSHOTS', defaultValue: false);
}
