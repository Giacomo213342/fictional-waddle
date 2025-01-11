import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../../../widgets/matrix/avatar_builder/mxc_avatar.dart';

class MxidPreviewPile extends StatelessWidget {
  const MxidPreviewPile({
    super.key,
    required this.client,
    this.room,
    required this.mxid,
    this.secondary,
    this.via,
    required this.fallback,
  });

  final Client client;
  final Room? room;
  final String? mxid;
  final String? secondary;
  final Set<String>? via;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final mxid = this.mxid;
    _LinkMetadata<String> fallback;
    Future<_LinkMetadata>? getMetadataFuture;
    if (mxid != null) {
      final prefix = mxid.sigil;
      switch (prefix) {
        case '@':
          final fallbackUser = room?.unsafeGetUserFromMemoryOrFallback(mxid);
          fallback = _LinkMetadata(
            label: fallbackUser?.calcDisplayname() ?? mxid,
            avatar: fallbackUser?.avatarUrl,
          );
          getMetadataFuture = _getUserProfile(mxid);
          break;
        case '#':
        case '!':
          final room = prefix == '#'
              ? client.getRoomByAlias(mxid)
              : client.getRoomById(mxid);
          if (room != null) {
            fallback = _LinkMetadata(
              label: room.getLocalizedDisplayname(),
              avatar: room.avatar,
            );
            break;
          }
          fallback = _LinkMetadata(label: mxid);
          getMetadataFuture = _getRoomPreview(mxid);

          break;
        default:
          fallback = _LinkMetadata(label: mxid);
      }
    } else {
      fallback = _LinkMetadata(label: this.fallback);
    }

    final secondary = this.secondary;
    final showTrailing = secondary != null;

    return FutureBuilder<_LinkMetadata<String?>>(
      future: getMetadataFuture,
      builder: (context, snapshot) {
        final label = snapshot.data?.label ?? fallback.label;
        final uri = snapshot.data?.avatar ?? fallback.avatar;
        return Chip(
          avatar: MxcAvatar(
            uri: uri,
            client: client,
            dimension: 24,
            monogram: label,
          ),
          label: Text(label),
          onDeleted: showTrailing ? () {} : null,
          deleteIcon: showTrailing ? const Icon(Icons.message) : null,
          deleteButtonTooltipMessage: showTrailing
              ? AppLocalizations.of(context).jumpToMessage(secondary)
              : null,
        );
      },
    );
  }

  Future<_LinkMetadata<String?>> _getUserProfile(String mxid) async {
    final user = await room?.requestUser(mxid);
    if (user != null) {
      return _LinkMetadata(
        label: user.calcDisplayname(),
        avatar: user.avatarUrl,
      );
    }

    final profile = await client.getProfileFromUserId(mxid);
    return _LinkMetadata(
      label: profile.displayName,
      avatar: profile.avatarUrl,
    );
  }

  Future<_LinkMetadata<String?>> _getRoomPreview(String mxid) async {
    final via = {
      ...?this.via,
      mxid.domain,
      null,
    };

    for (final server in via) {
      final response = await client.queryPublicRooms(
        server: server,
        filter: PublicRoomQueryFilter(
          genericSearchTerm: mxid,
        ),
      );
      final room = response.chunk.firstOrNull;
      if (room != null) {
        return _LinkMetadata(
          label: room.name,
          avatar: room.avatarUrl,
        );
      }
    }
    return _LinkMetadata(label: mxid);
  }
}

class _LinkMetadata<T extends String?> {
  const _LinkMetadata({this.avatar, required this.label});

  final Uri? avatar;
  final T label;
}
