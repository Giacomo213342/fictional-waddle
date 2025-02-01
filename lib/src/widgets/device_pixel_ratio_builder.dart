import 'package:flutter/widgets.dart';

typedef DevicePixelRatioBuilderCallback = Widget Function(
  BuildContext context,
  double pixelRatio,
);

class DevicePixelRatioBuilder extends StatefulWidget {
  const DevicePixelRatioBuilder({super.key, required this.builder});

  final DevicePixelRatioBuilderCallback builder;

  @override
  State<DevicePixelRatioBuilder> createState() =>
      _DevicePixelRatioBuilderState();
}

class _DevicePixelRatioBuilderState extends State<DevicePixelRatioBuilder>
    with WidgetsBindingObserver {
  double? _currentDevicePixelRatio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      if (pixelRatio != _currentDevicePixelRatio) {
        setState(() => _currentDevicePixelRatio = pixelRatio);
      }
    });
  }

  @override
  void didUpdateWidget(covariant DevicePixelRatioBuilder oldWidget) {
    if (oldWidget.builder != widget.builder) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final pixelRatio =
        _currentDevicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return widget.builder.call(context, pixelRatio);
  }
}
