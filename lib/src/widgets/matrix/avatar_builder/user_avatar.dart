import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/matrix/polycule_matrix_localizations.dart';
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
    final monogram = user.calcDisplayname(
      i18n: AppLocalizations.of(context).matrix,
    );

    return MxcAvatar(
      uri: uri,
      monogram: monogram,
      dimension: dimension,
    );
  }
}
