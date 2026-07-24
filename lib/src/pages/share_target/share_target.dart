import 'dart:async';

import 'package:flutter/material.dart';

import 'package:async/async.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/ascii_progress_indicator.dart';
import '../../widgets/android_predictive_back_scope.dart';
import '../../widgets/intent_manager.dart';
import '../../widgets/matrix/avatar_builder/profile_avatar_builder.dart';
import '../../widgets/matrix/avatar_builder/room_avatar.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';
import '../../widgets/matrix/client_manager/client_store.dart';
import '../../widgets/matrix/scopes/client_scope.dart';
import '../room/room.dart';
import '../room_list/room_list_ordering.dart';

class ShareTargetPage extends StatefulWidget {
  const ShareTargetPage({super.key});

  static const routeName = '/share';

  @override
  State<ShareTargetPage> createState() => _ShareTargetPageState();
}

class _ShareTargetPageState extends State<ShareTargetPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(_refresh);
    super.initState();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = ClientManager.of(context);
    return AndroidPredictiveBackScope(
      onBack: () => unawaited(_cancel()),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: _cancel,
          ),
          title: const Text('Send to…'),
        ),
        body: FutureBuilder<void>(
          future: manager.store.waiForInitialization,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: AsciiProgressIndicator());
            }
            return ValueListenableBuilder<List<Client>>(
              valueListenable: manager.store.activeClients,
              builder: (context, clients, _) => _buildRoomPicker(clients),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoomPicker(List<Client> clients) {
    final syncStreams = clients.map((client) => client.onSync.stream);
    return StreamBuilder<SyncUpdate>(
      stream: syncStreams.isEmpty ? null : StreamGroup.merge(syncStreams),
      builder: (context, _) {
        final targets = shareTargets(
          clients,
          query: _searchController.text,
        );
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SearchBar(
                controller: _searchController,
                autoFocus: false,
                hintText: AppLocalizations.of(context).search,
                leading: const Icon(Icons.search),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      onPressed: _searchController.clear,
                      icon: const Icon(Icons.clear),
                      tooltip:
                          MaterialLocalizations.of(context).deleteButtonTooltip,
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: targets.length,
                itemBuilder: (context, index) {
                  final target = targets[index];
                  return ListTile(
                    leading: _ShareTargetAvatar(target: target),
                    title: Text(target.room.getLocalizedDisplayname()),
                    subtitle: clients.length > 1
                        ? Text(target.client.userID ?? target.client.clientName)
                        : null,
                    onTap: () => _select(target),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _refresh() => setState(() {});

  void _select(ShareTarget target) {
    IntentManager.selectShareDestination(
      clientName: target.client.clientName,
      roomId: target.room.id,
    );
    final identifier = target.client.clientName.clientIdentifier;
    context.go(
      '/client/$identifier${RoomPage.makeRouteName(target.room.id)}',
    );
  }

  Future<void> _cancel() async {
    await IntentManager.claimShareIntent();
    if (!mounted) {
      return;
    }
    final clients = ClientManager.of(context).store.activeClients.value;
    final client = clients.firstOrNull;
    if (client == null) {
      context.go('/');
      return;
    }
    context.go('/client/${client.clientName.clientIdentifier}');
  }
}

@immutable
class ShareTarget {
  const ShareTarget(this.client, this.room);

  final Client client;
  final Room room;
}

class _ShareTargetAvatar extends StatelessWidget {
  const _ShareTargetAvatar({required this.target});

  final ShareTarget target;

  @override
  Widget build(BuildContext context) {
    final directUserId = target.room.directChatMatrixID;
    if (directUserId == null) {
      return RoomAvatar(room: target.room, dimension: 44);
    }
    return ClientScope(
      client: target.client,
      child: ProfileAvatarBuilder(
        userId: directUserId,
        dimension: 44,
      ),
    );
  }
}

List<ShareTarget> shareTargets(
  Iterable<Client> clients, {
  String query = '',
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final targets = <ShareTarget>[
    for (final client in clients)
      for (final room in client.rooms)
        if (room.membership == Membership.join &&
            !room.isSpace &&
            !room.isArchived)
          ShareTarget(client, room),
  ];
  if (normalizedQuery.isNotEmpty) {
    targets.removeWhere((target) {
      final room = target.room;
      return ![
        room.getLocalizedDisplayname(),
        room.name,
        room.topic,
        room.id,
        room.directChatMatrixID ?? '',
      ].any((value) => value.toLowerCase().contains(normalizedQuery));
    });
  }
  targets.sort((a, b) {
    final aTimestamp =
        a.room.lastEvent?.originServerTs.millisecondsSinceEpoch ?? 0;
    final bTimestamp =
        b.room.lastEvent?.originServerTs.millisecondsSinceEpoch ?? 0;
    return bTimestamp.compareTo(aTimestamp);
  });
  return normalBeforeLowPriority(
    targets,
    isLowPriority: (target) =>
        target.room.tags.containsKey(TagType.lowPriority),
  );
}
