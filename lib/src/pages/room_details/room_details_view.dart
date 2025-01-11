import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/matrix/avatar_builder/fullscreen_dialog_avatar.dart';
import '../../widgets/matrix/mxc_uri_image.dart';
import '../../widgets/polycule_html_view.dart';
import '../../widgets/share_origin_builder.dart';
import 'room_details.dart';

class RoomDetailsView extends StatelessWidget {
  const RoomDetailsView({super.key, required this.controller});

  final RoomDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final room = controller.widget.room;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: room.avatar == null ? null : 256,
            leading: CloseButton(
              onPressed: controller.close,
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                room.getLocalizedDisplayname(),
                overflow: TextOverflow.ellipsis,
              ),
              background: room.avatar == null
                  ? null
                  : FullScreenAvatar.makeImageButton(
                      context: context,
                      child: MxcUriImageBuilder(
                        uri: room.avatar,
                        client: controller.client,
                        fit: BoxFit.cover,
                      ),
                      client: controller.client,
                      uri: room.avatar,
                      title: room.getLocalizedDisplayname(),
                    ),
            ),
          ),
          SliverList.list(
            children: [
              if (room.topic.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SelectionArea(
                    child: PolyculeHtmlView(
                      html: room.topic.replaceAll('\n', r'<br />'),
                      globalKeyTag: room.id,
                      client: room.client,
                      room: room,
                    ),
                  ),
                ),
              if (room.canonicalAlias.isNotEmpty)
                ListTile(
                  title: ShareOriginBuilder(
                    builder: (context, rect) => ElevatedButton.icon(
                      onPressed: () => controller.sharePublicAddress(rect),
                      icon: const Icon(Icons.share),
                      label: Text(
                        room.canonicalAlias,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => Clipboard.setData(
                      ClipboardData(text: room.canonicalAlias),
                    ),
                    icon: const Icon(Icons.copy),
                    tooltip: AppLocalizations.of(context).copyRoomAddress,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
