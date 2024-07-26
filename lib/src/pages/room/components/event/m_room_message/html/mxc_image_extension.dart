import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:matrix/matrix.dart';

import '../../../../../../utils/parent_font_size_extension.dart';
import '../../../../../../widgets/matrix/mxc_uri_image.dart';

class MxcImageExtension extends ImageExtension {
  MxcImageExtension(Client client)
      : super(
          handleAssetImages: false,
          handleDataImages: false,
          handleNetworkImages: true,
          networkSchemas: {'mxc'},
          builder: (extensionContext) {
            final isEmote =
                extensionContext.attributes.containsKey('data-mx-emoticon') ||
                    extensionContext.attributes.containsKey('data-mx-emoji');

            double? width, height;
            if (isEmote) {
              final fontSize =
                  extensionContext.tryGetParentFontSize()?.emValue ?? 12;
              width = height = fontSize * 1.25;
            } else {
              final widthString = extensionContext.attributes['width'];
              if (widthString is String) {
                width = double.tryParse(widthString);
              }
              final heightString = extensionContext.attributes['height'];
              if (heightString is String) {
                height = double.tryParse(heightString);
              }
            }
            return Tooltip(
              message: extensionContext.attributes['alt'],
              child: SizedBox(
                height: height,
                width: width,
                child: MxcUriImageBuilder(
                  uri: Uri.parse(extensionContext.attributes['src']!),
                  client: client,
                  width: width,
                  height: height,
                ),
              ),
            );
          },
        );
}
