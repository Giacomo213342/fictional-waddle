final class Users {
  const Users._({
    required this.username,
    required this.password,
    required this.displayName,
  });

  static const alice = Users._(
    username: 'alice',
    password: 'AliceInWonderland',
    displayName: 'Alice van Wonderland',
  );

  static const bob = Users._(
    username: 'bob',
    password: 'JoWirSchaffenDas',
    displayName: 'Bob Baumeister',
  );

  static const all = [alice, bob];

  final String username;
  final String password;
  final String displayName;
}
