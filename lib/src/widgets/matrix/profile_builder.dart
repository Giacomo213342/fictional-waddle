import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class ProfileBuilder extends StatelessWidget {
  const ProfileBuilder({
    super.key,
    required this.userId,
    required this.client,
    required this.builder,
  });

  final String userId;
  final Client client;
  final AsyncWidgetBuilder<Profile> builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      key: ValueKey(userId),
      stream: client.onUserProfileUpdate.stream.where((user) => user == userId),
      builder: (context, snapshot) {
        return FutureBuilder(
          future: client.getProfileFromUserId(userId),
          builder: builder,
        );
      },
    );
  }
}
