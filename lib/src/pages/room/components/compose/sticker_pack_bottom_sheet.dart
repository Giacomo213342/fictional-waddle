import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../widgets/matrix/avatar_builder/mxc_avatar.dart';
import '../../../../widgets/matrix/mxc_uri_image.dart';

class StickerPackBottomSheet extends StatelessWidget {
  const StickerPackBottomSheet({super.key, required this.room});

  final Room room;

  Future<ImagePackImageContent?> showBottomSheet(BuildContext context) {
    return showModalBottomSheet<ImagePackImageContent>(
      context: context,
      builder: (context) => this,
      clipBehavior: Clip.hardEdge,
    );
  }

  @override
  Widget build(BuildContext context) {
    final packs = room.getImagePacks(ImagePackUsage.sticker);
    if (packs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            AppLocalizations.of(context).noStickerPacks,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (packs.length == 1) {
      return StickerPackPreview(
        content: packs.values.first,
        client: room.client,
      );
    } else {
      return DefaultTabController(
        length: packs.length,
        child: Column(
          children: [
            TabBar(
              tabs: packs.keys.map(
                (name) {
                  final pack = packs[name];
                  final url = pack?.pack.avatarUrl;
                  final displayName = pack?.pack.displayName ?? name;
                  return Tab(
                    text: displayName,
                    icon: url == null
                        ? null
                        : MxcAvatar(
                            uri: url,
                            client: room.client,
                            monogram: displayName,
                            dimension: 24,
                          ),
                  );
                },
              ).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: packs.values
                    .map(
                      (pack) => StickerPackPreview(
                        content: pack,
                        client: room.client,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class StickerPackPreview extends StatelessWidget {
  const StickerPackPreview({
    super.key,
    required this.content,
    required this.client,
  });

  final ImagePackContent content;
  final Client client;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 128,
        mainAxisExtent: 128,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      shrinkWrap: true,
      itemCount: content.images.length,
      itemBuilder: (context, index) {
        final key = content.images.keys.elementAt(index);
        return StickerPreview(
          name: key,
          content: content.images[key]!,
          client: client,
        );
      },
    );
  }
}

class StickerPreview extends StatelessWidget {
  const StickerPreview({
    super.key,
    required this.name,
    required this.content,
    required this.client,
  });

  final String name;
  final ImagePackImageContent content;
  final Client client;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(content),
      child: MxcUriImageBuilder(
        uri: content.url,
        client: client,
        width: 256,
        height: 256,
      ),
    );
  }
}
