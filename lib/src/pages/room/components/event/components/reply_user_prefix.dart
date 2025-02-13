import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/human_date.dart';
import '../../../../../widgets/matrix/avatar_builder/mxc_avatar.dart';
import '../../../../../widgets/matrix/scopes/event_scope.dart';

class ReplyUserPrefix extends StatelessWidget {
  const ReplyUserPrefix({super.key});

  @override
  Widget build(BuildContext context) {
    final event = EventScope.of(context).event;
    return FutureBuilder(
      future: event.fetchSenderUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? event.senderFromMemoryOrFallback;
        final name = user.displayName ?? user.id;
        return Text.rich(
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: MxcAvatar(
                  uri: user.avatarUrl,
                  monogram: name,
                  dimension: 24,
                ),
              ),
              TextSpan(
                text: r' ' +
                    AppLocalizations.of(context).replyUserSentDate(
                      name,
                      event.originServerTs.humanShortDate(
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
