import 'dart:io';

import 'package:polycule/src/utils/dart_environment.dart';

final homeserver =
    Platform.environment['HOMESERVER'] ?? DartEnvironment.homeserver;

String? ssss;
