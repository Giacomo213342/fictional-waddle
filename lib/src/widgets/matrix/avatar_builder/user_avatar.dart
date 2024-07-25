import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'mxc_avatar.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    required this.client,
    this.dimension = 48,
  });

  final User user;
  final Client client;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    final uri = user.avatarUrl;
    final monogram = user.calcDisplayname();

    return MxcAvatar(
      uri: uri,
      client: client,
      monogram: monogram,
      dimension: dimension,
    );
  }
}
