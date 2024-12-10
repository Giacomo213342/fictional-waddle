import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../../../utils/matrix/command_localization_helper.dart';
import '../../../widgets/matrix/avatar_builder/profile_avatar_builder.dart';
import '../room_list.dart';
import 'command_preview_tile.dart';
import 'room_list_tile.dart';

class RoomSearchBar extends StatelessWidget {
  const RoomSearchBar({super.key, required this.controller});

  final RoomListController controller;

  @override
  Widget build(BuildContext context) {
    final cmdL10nHelper =
        CommandLocalizationHelper(AppLocalizations.of(context));
    return SafeArea(
      child: SearchAnchor(
        searchController: controller.searchController,
        builder: (context, searchController) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              // 16 - 1 px of border gap
              horizontal: 15,
              vertical: 4,
            ),
            child: SearchBar(
              controller: searchController,
              focusNode: controller.searchFocus,
              onTap: () {
                searchController.openView();
              },
              onChanged: (_) {
                searchController.openView();
              },
              onSubmitted: controller.searchSubmitted,
              hintText: AppLocalizations.of(context).hajUser(
                controller.client.userID,
              ),
              leading: IconButton(
                onPressed: searchController.openView,
                tooltip: MaterialLocalizations.of(context).searchFieldLabel,
                icon: const Icon(Icons.search),
              ),
              trailing: [
                IconButton(
                  onPressed: controller.accountSettings,
                  tooltip: AppLocalizations.of(context).accountSettings,
                  icon: ProfileAvatarBuilder(
                    userId: controller.client.userID!,
                    client: controller.client,
                    dimension: 32,
                  ),
                ),
              ],
            ),
          );
        },
        headerHeight: 56 - 1,
        suggestionsBuilder: (_, searchController) {
          final query = searchController.text;
          final rooms = controller.filterRooms(query).map(
                (room) => RoomListTile(
                  controller,
                  room: room,
                  clientifyLocationCallback: context.clientifyLocation,
                  onActivate: () => searchController.closeView(
                    room.getLocalizedDisplayname(),
                  ),
                ),
              );
          List<Widget> commands = [];
          if (query.startsWith('/')) {
            final command = query.split(' ').first.substring(1);
            final msg = query.replaceFirst('/$command', '').trim();
            final args = CommandArgs(
              msg: msg,
              client: controller.client,
            );

            commands = controller.client.commands.keys
                .where((cmd) => cmd.startsWith(command))
                .map(
                  (cmd) => CommandPreviewTile(
                    controller: controller,
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
