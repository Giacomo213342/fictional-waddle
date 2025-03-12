import 'dart:io';

import 'package:matrix/matrix.dart';

import '../users.dart';

final homeserver = Platform.environment['HOMESERVER'] ??
    const String.fromEnvironment(
      'HOMESERVER',
      defaultValue: 'http://homeserver',
    );

Future<void> main([List<String>? args]) async {
  final client = Client('alice');
  client.homeserver = Uri.parse(homeserver);

  for (final user in Users.all) {
    await client.register(
      username: user.username,
      password: user.password,
      inhibitLogin: true,
      kind: AccountKind.user,
    );
    await client.logout();
  }
}
