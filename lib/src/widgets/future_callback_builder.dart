import 'package:flutter/material.dart';

typedef FutureCallback = Future<void> Function();
typedef FutureCallbackHandlerBuilder = Widget Function(
  BuildContext context,
  FutureCallback? callback,
  bool loading,
);

class FutureCallbackBuilder extends StatefulWidget {
  const FutureCallbackBuilder({
    super.key,
    required this.callback,
    required this.builder,
  });

  final FutureCallback? callback;
  final FutureCallbackHandlerBuilder builder;

  @override
  State<FutureCallbackBuilder> createState() => _FutureCallbackBuilderState();
}

class _FutureCallbackBuilderState extends State<FutureCallbackBuilder> {
  bool loading = false;

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        loading || widget.callback == null ? null : callback,
        loading,
      );

  Future<void> callback() async {
    setState(() {
      loading = true;
    });
    try {
      await widget.callback?.call();
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }
}
