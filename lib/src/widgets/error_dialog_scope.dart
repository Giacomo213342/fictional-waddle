import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/error_logger.dart';
import 'error_handler_dialog.dart';
import 'settings_manager.dart';

class ErrorDialogScope extends StatefulWidget {
  const ErrorDialogScope({super.key, required this.child});

  final Widget child;

  @override
  State<ErrorDialogScope> createState() => _ErrorDialogScopeState();
}

class _ErrorDialogScopeState extends State<ErrorDialogScope> {
  StreamSubscription<(Object?, StackTrace?)>? _errorListener;

  @override
  void initState() {
    _listenErrorLogging();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    _errorListener?.cancel();
    super.dispose();
  }

  void _listenErrorLogging() {
    _errorListener = ErrorLogger().errorStream.listen(_showErrorDialog);
  }

  Future<void> _showErrorDialog((Object?, StackTrace?) event) async {
    if (!SettingsManager.of(context).initCompleter.isCompleted) {
      await SettingsManager.of(context).initCompleter.future;
    }
    if (!mounted) {
      return;
    }
    if (SettingsManager.of(context).sentryEnabled.value == true) {
      return;
    }
    await ErrorHandlerDialog(
      error: event.$1,
      stackTrace: event.$2,
    ).showDialog(context);
  }
}
