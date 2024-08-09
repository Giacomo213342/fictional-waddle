import 'package:flutter/widgets.dart';

typedef ShareOriginBuilderCallback = Widget Function(
  BuildContext context,
  Rect? shareOriginRect,
);

class ShareOriginBuilder extends StatelessWidget {
  const ShareOriginBuilder({
    super.key,
    required this.builder,
  });

  final ShareOriginBuilderCallback builder;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        Rect? rect;
        final box = context.findRenderObject();
        if (box is RenderBox) {
          rect = box.localToGlobal(Offset.zero) & box.size;
        }
        return builder.call(context, rect);
      },
    );
  }
}
