import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../router/extensions/go_router_path_extension.dart';
import '../../widgets/matrix/client_scope.dart';
import '../../widgets/matrix/command_error_dialog.dart';
import '../account_settings/account_settings.dart';
import '../room/room.dart';
import '../ssss_bootstrap/ssss_bootstrap.dart';
import 'room_list_view.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  static const routeName = '/rooms';

  @override
  State<RoomListPage> createState() => RoomListController();
}

class _RoomListScope extends InheritedWidget {
  const _RoomListScope({
    required this.controller,
    required super.child,
  });

  final RoomListController controller;

  @override
  bool updateShouldNotify(covariant _RoomListScope oldWidget) =>
      controller != oldWidget.controller;
}

class RoomListController extends State<RoomListPage> {
  static RoomListController of(BuildContext context) {
    final _RoomListScope scope =
        context.dependOnInheritedWidgetOfExactType<_RoomListScope>()!;
    return scope.controller;
  }

  static final Map<String, FocusNode> _focusNodes = {};

  final searchController = SearchController();
  final searchFocus = FocusNode();

  List<Room> getRegularRooms() => ClientScope.of(context)
      .client
      .rooms
      .where((r) => !r.isSpace && !r.isArchived)
      .toList();

  /// provides the [FocusNode] for the room list tile of the given Room [id].
  static FocusNode getFocusNode(String id) {
    FocusNode? node = _focusNodes[id];
    return node ??= _focusNodes[id] = FocusNode();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _processFirstSync());
    super.initState();
  }

  @override
  Widget build(BuildContext context) => _RoomListScope(
        controller: this,
        child: RoomListView(this),
      );

  @override
  void dispose() {
    super.dispose();
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
    await client.onSync.stream.first;
    if (!mounted) {
      return;
    }
    _focusFirstRoom();
    await _checkSSSS(client);
  }

  /// checks whether our room list contains any item and tries to focus it
  /// In case of success, it cancels the further sync listener
  void _focusFirstRoom() {
    final firstRoom = getRegularRooms().firstOrNull;
    if (firstRoom == null) {
      return;
    }
    final node = getFocusNode(firstRoom.id);
    if (!node.canRequestFocus) {
      return;
    }
    node.requestFocus();
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
            (command) => command.startsWith(
              query.split(' ').first.substring(1),
            ),
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
    final room = filterRooms(query).first;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
        ),
      );
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
