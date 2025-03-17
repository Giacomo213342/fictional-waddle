import 'dart:io';

final homeserver = Platform.environment['HOMESERVER'] ??
    const String.fromEnvironment(
      'HOMESERVER',
      defaultValue: 'http://homeserver',
    );

String? ssss;
