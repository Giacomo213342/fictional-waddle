import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../../../utils/matrix/command_localization_helper.dart';
import '../../../widgets/matrix/avatar_builder/profile_avatar_builder.dart';
import '../../../widgets/matrix/scopes/client_scope.dart';
import '../../../widgets/matrix/scopes/room_scope.dart';
import '../room_list.dart';
import 'command_preview_tile.dart';
import 'room_list_tile.dart';

class RoomSearchBar extends StatelessWidget {
  const RoomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = ClientScope.of(context).client.userID;
    final cmdL10nHelper =
        CommandLocalizationHelper(AppLocalizations.of(context));
    final controller = RoomListController.of(context);
    return SafeArea(
      bottom: false,
      child: SearchAnchor(
        searchController: controller.searchController,
        builder: (context, _) => Padding(
          padding: const EdgeInsets.symmetric(
            // 16 - 1 px of border gap
            horizontal: 15,
            vertical: 4,
          ),
          child: SearchViewLauncher(
            label: AppLocalizations.of(context).searchPromptLabel,
            onPressed: controller.search,
            accountButton: IconButton(
              onPressed: controller.accountSettings,
              tooltip: AppLocalizations.of(context).accountSettings,
              icon: ProfileAvatarBuilder(
                userId: userId ?? '',
                dimension: 32,
              ),
            ),
          ),
        ),
        headerHeight: 56 - 1,
        suggestionsBuilder: (context, searchController) {
          final client = ClientScope.of(context).client;
          final query = searchController.text;
          final rooms = controller.filterRooms(query).map(
                (room) => RoomScope(
                  room: room,
                  child: RoomListTile(
                    key: Key(room.id),
                    clientifyLocationCallback: context.clientifyLocation,
                    onActivate: () => searchController.closeView(
                      room.getLocalizedDisplayname(),
                    ),
                  ),
                ),
              );
          List<Widget> commands = [];
          if (query.startsWith('/')) {
            final command = query.split(' ').first.substring(1);
            final msg = query.replaceFirst('/$command', '').trim();
            final args = CommandArgs(msg: msg, client: client);

            commands = client.commands.keys
                .where((cmd) => cmd.startsWith(command))
                .map(
                  (cmd) => CommandPreviewTile(
                    command: cmd,
                    description: cmdL10nHelper.lookupCommandDescription(cmd),
                    args: args,
                  ),
                )
                .toList();
          }

          return [...commands, ...rooms];
        },
        viewOnSubmitted: controller.searchSubmitted,
        viewBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        viewConstraints: const BoxConstraints(minHeight: double.maxFinite),
        viewHintText: AppLocalizations.of(context).searchPromptLabel,
      ),
    );
  }
}

class SearchViewLauncher extends StatelessWidget {
  const SearchViewLauncher({
    super.key,
    required this.label,
    required this.onPressed,
    required this.accountButton,
  });

  final String label;
  final VoidCallback onPressed;
  final Widget accountButton;

  @override
  Widget build(BuildContext context) {
    final searchTheme = SearchBarTheme.of(context);
    final states = <WidgetState>{};
    final background = searchTheme.backgroundColor?.resolve(states) ??
        Theme.of(context).colorScheme.surface;
    final shape = searchTheme.shape?.resolve(states) ?? const StadiumBorder();

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: background,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.search),
                ),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                accountButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
