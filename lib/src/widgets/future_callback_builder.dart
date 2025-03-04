import 'package:flutter/material.dart';

import 'package:async/async.dart';

typedef FutureCallback = Future<void> Function();
typedef FutureCallbackHandlerBuilder = Widget Function(
  BuildContext context,
  FutureCallback? callback,
  bool loading,
  VoidCallback? cancel,
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
  CancelableOperation<void>? operation;

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        operation != null || widget.callback == null ? null : _callback,
        operation != null,
        operation?.cancel,
      );

  CancelableOperation<void>? _operation() {
    final callback = widget.callback;
    if (callback == null) {
      return null;
    }
    return CancelableOperation.fromFuture(callback.call());
  }

  Future<void> _callback() async {
    setState(() {
      operation = _operation();
    });
    try {
      await operation?.valueOrCancellation();
    } finally {
      if (mounted) {
        setState(() {
          operation = null;
        });
      }
    }
  }
}
