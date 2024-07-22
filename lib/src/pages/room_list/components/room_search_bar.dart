import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../room_list.dart';
import 'room_list_tile.dart';

class RoomSearchBar extends StatelessWidget {
  const RoomSearchBar({super.key, required this.controller});

  final RoomListController controller;

  @override
  Widget build(BuildContext context) {
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
            ),
          );
        },

        headerHeight: 56 - 1,
        suggestionsBuilder: (_, searchController) =>
            controller.filterRooms(searchController.text).map(
                  (room) => RoomListTile(
                    controller,
                    room: room,
                    clientifyLocationCallback: context.clientifyLocation,
                    onActivate: () => searchController.closeView(
                      room.getLocalizedDisplayname(),
                    ),
                  ),
                ),
        viewOnSubmitted: controller.searchSubmitted,

        // viewBackgroundColor: Colors.transparent,
        viewConstraints: const BoxConstraints(minHeight: double.maxFinite),
        viewHintText: AppLocalizations.of(context).searchPromptLabel,
      ),
    );
  }
}
