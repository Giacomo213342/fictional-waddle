import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../widgets/matrix/avatar_builder/profile_avatar_builder.dart';
import '../../../widgets/matrix/profile_builder.dart';

class OwnProfilePreview extends StatelessWidget {
  const OwnProfilePreview({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final userId = client.userID!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          ProfileAvatarBuilder(
            userId: userId,
            client: client,
            dimension: 96,
          ),
          const SizedBox(width: 24),
          Flexible(
            flex: 1,
            child: ProfileBuilder(
              userId: userId,
              client: client,
              builder: (context, snapshot) {
                final displayName =
                    snapshot.data?.displayName ?? userId.localpart ?? userId;
                return Text(
                  displayName,
                  maxLines: 3,
                  style: Theme.of(context).textTheme.headlineSmall,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
