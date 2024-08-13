import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/human_date.dart';
import '../../../../../widgets/matrix/avatar_builder/mxc_avatar.dart';

class ReplyUserPrefix extends StatelessWidget {
  const ReplyUserPrefix({super.key, required this.replyEvent});

  final Event replyEvent;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: replyEvent.fetchSenderUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? replyEvent.senderFromMemoryOrFallback;
        final name = user.displayName ?? user.id;
        return Text.rich(
          textAlign: TextAlign.center,
          TextSpan(
            children: [
              WidgetSpan(
                child: MxcAvatar(
                  uri: user.avatarUrl,
                  client: replyEvent.room.client,
                  monogram: name,
                  dimension: 24,
                ),
              ),
              TextSpan(
                text: r' ' +
                    AppLocalizations.of(context).replyUserSentDate(
                      name,
                      replyEvent.originServerTs.humanShortDate(
                        context: context,
                        fullLength: true,
                      ),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
