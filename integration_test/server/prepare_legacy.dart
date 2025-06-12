// ignore_for_file: avoid_print

import 'dart:io';

import 'package:matrix/matrix.dart';
import 'package:polycule/src/utils/dart_environment.dart';
import 'package:polycule/src/utils/matrix/msc_3231_registration_token.dart';

import '../users.dart';

final homeserver =
    Platform.environment['HOMESERVER'] ?? DartEnvironment.homeserver;

Future<void> main([List<String>? args]) async {
  Logs().level = Level.debug;
  print('Registering ${Users.all.length} users at $homeserver ...');
  final client = Client(
    'integration_setup',
    database: await MatrixSdkDatabase.init('integration_setup'),
  );
  client.homeserver = Uri.parse(homeserver);
  client.onUiaRequest.stream.listen((request) {
    if (request.nextStages.contains(
      Msc3231AuthenticationRegistrationToken.authType,
    )) {
      request.completeStage(
        Msc3231AuthenticationRegistrationToken(
          token: Users.registrationToken,
          session: request.session,
        ),
      );
    } else if (request.nextStages.contains(AuthenticationTypes.dummy)) {
      request.completeStage(
        AuthenticationData(
          type: AuthenticationTypes.dummy,
          session: request.session,
        ),
      );
    } else {
      print('Unknown UIA stages ${request.nextStages}');
    }
  });
  for (final user in Users.all) {
    print('Registering ${user.username} ...');

    try {
      await client.uiaRequestBackground<RegisterResponse>(
        (auth) => client.register(
          username: user.username,
          password: user.password,
          inhibitLogin: true,
          auth: auth,
        ),
      );
    } catch (_) {
      print('Registered ${user.username}.');
    }
  }
  await client.dispose();

  print('All clients disposed.');
}
