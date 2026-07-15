import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../../widgets/human_date.dart';
import '../../../widgets/matrix/client_manager/client_store.dart';
import '../../../widgets/matrix/scopes/room_scope.dart';

class RoomSearchDialog extends StatefulWidget {
  const RoomSearchDialog({super.key});

  @override
  State<RoomSearchDialog> createState() => _RoomSearchDialogState();
}

class _RoomSearchDialogState extends State<RoomSearchDialog> {
  final _controller = TextEditingController();
  Future<List<Event>>? _results;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: const CloseButton(),
          title: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Search messages',
              border: InputBorder.none,
            ),
            onSubmitted: _search,
          ),
          actions: [
            IconButton(
              onPressed: () => _search(_controller.text),
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        body: _results == null
            ? const Center(child: Text('Search this conversation'))
            : FutureBuilder<List<Event>>(
                future: _results,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Search failed: ${snapshot.error}'),
                      ),
                    );
                  }
                  final events = snapshot.data ?? const [];
                  if (events.isEmpty) {
                    return const Center(child: Text('No messages found'));
                  }
                  return ListView.separated(
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final body = event.content['body']?.toString() ??
                          event.content['m.text']?.toString() ??
                          event.type;
                      return ListTile(
                        leading: const Icon(Icons.chat_bubble_outline),
                        title: Text(
                          body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text([
                          event.senderId,
                          event.originServerTs.humanShortDate(context: context),
                        ].join(' · ')),
                        onTap: () => _openResult(event),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  void _search(String query) {
    final term = query.trim();
    if (term.isEmpty) {
      return;
    }
    final room = RoomScope.of(context).room;
    setState(() {
      _results = _searchRoom(room, term);
    });
  }

  Future<List<Event>> _searchRoom(Room room, String term) async {
    final timeline = await room.getTimeline();
    var found = <Event>[];
    try {
      await for (final result in timeline.startSearch(
        searchTerm: term,
        limit: 50,
      )) {
        found = List<Event>.from(result.$1);
      }
      return found;
    } finally {
      timeline.cancelSubscriptions();
    }
  }

  void _openResult(Event event) {
    final room = RoomScope.of(context).room;
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    final route = '/client/${room.client.clientName.clientIdentifier}'
        '/rooms/${Uri.encodeComponent(room.id)}'
        '#${Uri.encodeComponent(event.eventId)}';
    router.go(route);
  }
}
