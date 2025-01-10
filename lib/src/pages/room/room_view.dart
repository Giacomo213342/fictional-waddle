import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/link.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../router/extensions/go_router_path_extension.dart';
import '../../widgets/matrix/avatar_builder/room_avatar.dart';
import '../../widgets/matrix/avatar_builder/room_builder.dart';
import '../user_page/user_page.dart';
import 'components/room_body.dart';
import 'components/room_encryption_inficator.dart';
import 'room.dart';

class RoomView extends StatelessWidget {
  const RoomView(this.controller, {super.key});

  final RoomController controller;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
            controller.focusBack,
        const SingleActivator(LogicalKeyboardKey.escape): controller.focusBack,
      },
      child: Focus(
        autofocus: true,
        // the focus node ensures we can request initial keyboard focus
        focusNode: controller.focusNode,
        child: Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(2),
              child: RoomBuilder(
                room: controller.room,
                builder: (context, snapshot) {
                  final room = snapshot.data ?? controller.room;
                  return RoomAvatar.fullScreenButton(
                    context: context,
                    room: room,
                    dimension: 64,
                  );
                },
              ),
            ),
            title: RoomBuilder(
              room: controller.room,
              builder: (context, snapshot) {
                final room = snapshot.data ?? controller.room;
                Uri? link;
                if (room.isDirectChat) {
                  link = Uri.parse(
                    context.clientifyLocation(
                      UserPage.makeRouteName(room.directChatMatrixID),
                    ),
                  );
                }
                final style = DefaultTextStyle.of(context);
                return Link(
                  uri: link,
                  builder: (context, followLink) {
                    return TextButton(
                      onPressed: followLink,
                      child: DefaultTextStyle(
                        style: style.style,
                        overflow: style.overflow,
                        textAlign: style.textAlign,
                        softWrap: style.softWrap,
                        maxLines: style.maxLines,
                        child: Text(
                          room.getLocalizedDisplayname(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: AppLocalizations.of(context).search,
                onPressed: () {},
              ),
              RoomEncryptionIndicator(room: controller.room),
            ],
          ),
          body: Semantics(
            hint: AppLocalizations.of(context).regionChatContents,
            child: RoomBody(
              controller: controller,
              key: ValueKey(controller.room.id),
            ),
          ),
        ),
      ),
    );
  }
}
