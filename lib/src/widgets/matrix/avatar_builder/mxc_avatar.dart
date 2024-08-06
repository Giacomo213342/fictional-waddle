import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../mxc_uri_image.dart';
import 'components/monogram_text.dart';

class MxcAvatar extends StatelessWidget {
  const MxcAvatar({
    super.key,
    required this.uri,
    required this.client,
    required this.monogram,
    required this.dimension,
  });

  static const kFadeDuration = Duration(milliseconds: 300);

  final Uri? uri;
  final Client client;
  final String monogram;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    final factor = dimension / 48;
    final style = Theme.of(context).textTheme.headlineMedium;
    double? size = style?.fontSize;
    if (size != null) {
      size *= factor;
    }

    return Semantics(
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: dimension,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          child: ClipRRect(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: MxcUriImageBuilder(
                key: ValueKey(uri),
                uri: uri,
                client: client,
                width: dimension - 4,
                height: dimension - 4,
                imageBuilder: (context, snapshot, retryCallback) {
                  final image = snapshot.data;
                  return Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      AnimatedOpacity(
                        opacity: image == null ? 0 : 1,
                        duration: kFadeDuration,
                        curve: Curves.easeInOut,
                        child: image,
                      ),
                      AnimatedOpacity(
                        opacity: image == null ? 1 : 0,
                        duration: kFadeDuration,
                        curve: Curves.easeInOut,
                        child: InkWell(
                          onTap: retryCallback,
                          child: Center(
                            child: MonogramText(
                              monogram,
                              style: style?.copyWith(fontSize: size),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
