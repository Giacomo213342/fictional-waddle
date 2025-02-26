import 'package:flutter/material.dart';

import '../../avatar_builder/mxc_avatar.dart';
import '../../profile_builder.dart';
import '../../scopes/sas_scope.dart';

class SasProfile extends StatelessWidget {
  const SasProfile({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: ProfileBuilder(
          userId: SasScope.of(context).verification.userId,
          builder: (context, snapshot) => MxcAvatar(
            uri: snapshot.data?.avatarUrl,
            monogram: snapshot.data?.displayName ??
                SasScope.of(context).verification.userId,
            dimension: 64,
          ),
        ),
      );
}
