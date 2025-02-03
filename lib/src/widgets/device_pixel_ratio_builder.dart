import 'package:flutter/widgets.dart';

typedef DevicePixelRatioBuilderCallback = Widget Function(
  BuildContext context,
  double pixelRatio,
);

class DevicePixelRatioBuilder extends StatelessWidget {
  const DevicePixelRatioBuilder({super.key, required this.builder});

  final DevicePixelRatioBuilderCallback builder;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return builder.call(context, pixelRatio);
  }
}
