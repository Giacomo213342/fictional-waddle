import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../router/extensions/go_router_path_extension.dart';
import '../../widgets/matrix/dialogs/command_error_dialog.dart';
import '../../widgets/matrix/scopes/client_scope.dart';
import '../account_settings/account_settings.dart';
import '../room/room.dart';
import '../ssss_bootstrap/ssss_bootstrap.dart';
import 'room_list_ordering.dart';
import 'room_list_position_tracker.dart';
import 'room_list_view.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  static const routeName = '/rooms';

  @override
  State<RoomListPage> createState() => RoomListController();
}

class _RoomListScope extends InheritedWidget {
  const _RoomListScope({required this.controller, required super.child});

  final RoomListController controller;

  @override
  bool updateShouldNotify(covariant _RoomListScope oldWidget) =>
      controller != oldWidget.controller;
}

class RoomListController extends State<RoomListPage> {
  static RoomListController of(BuildContext context) {
    final _RoomListScope scope = context
        .dependOnInheritedWidgetOfExactType<_RoomListScope>()!;
    return scope.controller;
  }

  final searchController = SearchController();
  final searchFocus = FocusNode();
  final scrollController = ScrollController();
  static final Map<String, double> _savedOffsets = {};
  String? _clientName;
  bool _restoredOffset = false;

  List<Room> getRegularRooms() {
    final rooms = ClientScope.of(
      context,
    ).client.rooms.where((r) => !r.isSpace && !r.isArchived).toList();
    return normalBeforeLowPriority(
      rooms,
      isLowPriority: (room) => room.tags.containsKey(TagType.lowPriority),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _processFirstSync());
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final clientName = ClientScope.of(context).client.clientName;
    if (_clientName == clientName) return;
    if (_clientName != null) {
      RoomListPositionTracker.unregister(_clientName!, _resetToTop);
    }
    _clientName = clientName;
    RoomListPositionTracker.register(clientName, _resetToTop);
    scrollController.addListener(_saveOffset);
    if (!_restoredOffset) {
      _restoredOffset = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !scrollController.hasClients) return;
        final offset = _savedOffsets[clientName] ?? 0;
        scrollController.jumpTo(
          offset.clamp(0, scrollController.position.maxScrollExtent).toDouble(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
      _RoomListScope(controller: this, child: RoomListView(this));

  @override
  void dispose() {
    final clientName = _clientName;
    if (clientName != null) {
      RoomListPositionTracker.unregister(clientName, _resetToTop);
    }
    scrollController
      ..removeListener(_saveOffset)
      ..dispose();
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  void _saveOffset() {
    final clientName = _clientName;
    if (clientName != null && scrollController.hasClients) {
      _savedOffsets[clientName] = scrollController.offset;
    }
  }

  void _resetToTop() {
    final clientName = _clientName;
    if (clientName != null) _savedOffsets[clientName] = 0;
    if (!scrollController.hasClients) return;
    scrollController.jumpTo(0);
  }

  List<Room> filterRooms(String filter) {
    filter = filter.toLowerCase();
    return getRegularRooms()
        .where(
          (room) =>
              room.name.toLowerCase().contains(filter) ||
              room.topic.toLowerCase().contains(filter) ||
              (room.directChatMatrixID?.toLowerCase().contains(filter) ??
                  false) ||
              room.getLocalizedDisplayname().toLowerCase().contains(filter) ||
              room.id.toLowerCase().contains(filter),
        )
        .toList();
  }

  Future<void> _processFirstSync() async {
    final client = ClientScope.of(context).client;
    unawaited(_checkSSSS(client));
    // wait for all basic data to be synced
    await client.accountDataLoading;
    await client.roomsLoading;
    if (client.onSync.value == null) {
      await client.onSync.stream.first;
    }
    if (!mounted) {
      return;
    }
    await _checkSSSS(client);
  }

  void search() {
    searchFocus.requestFocus();
    searchController.text = '';
    searchController.openView();
  }

  void command() {
    searchFocus.requestFocus();
    searchController.value = const TextEditingValue(
      text: '/',
      composing: TextRange(start: 1, end: 1),
    );
    searchController.openView();
  }

  void searchSubmitted(String query) {
    final client = ClientScope.of(context).client;
    if (query.startsWith('/')) {
      final command = client.commands.keys
          .where(
            (command) =>
                command.startsWith(query.split(' ').first.substring(1)),
          )
          .firstOrNull;

      if (command != null) {
        final args = CommandArgs(
          msg: query.replaceFirst('/$command', '').trim(),
          client: client,
        );
        runCommand(command, args);
        return;
      }
    }
    final room = filterRooms(query).firstOrNull;
    if (room == null) return;

    searchController.closeView('');
    searchFocus.unfocus();

    context.goMultiClient(RoomPage.makeRouteName(room.id));
  }

  Future<void> runCommand(String command, CommandArgs args) async {
    final stdout = StringBuffer();
    final callback = ClientScope.of(context).client.commands[command];
    try {
      await callback?.call(args, stdout);
      final result = stdout.toString();
      searchController.closeView(null);
      if (result.isEmpty || !mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    } on CommandException catch (e) {
      if (!mounted) {
        return;
      }
      await CommandErrorDialog(error: e).show(context);
    }
  }

  void accountSettings() {
    context.goMultiClient(AccountSettings.routeName);
  }

  Future<void> _checkSSSS(Client client) async {
    if (client.isUnknownSession ||
        await client.encryption?.crossSigning.isCached() == false ||
        await client.encryption?.keyManager.isCached() == false) {
      if (mounted) {
        context.goMultiClient(SsssBootstrapPage.routeName);
      }
    }
  }
}
