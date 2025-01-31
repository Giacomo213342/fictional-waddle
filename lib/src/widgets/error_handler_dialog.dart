import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:url_launcher/link.dart';

import '../../l10n/generated/app_localizations.dart';
import '../pages/application_settings/application_settings.dart';
import '../pages/application_settings/pages/error_reporting.dart';
import '../pages/application_settings/pages/logs/log_row.dart';
import '../utils/error_logger.dart';
import 'settings_manager.dart';

class ErrorHandlerDialog extends StatelessWidget {
  const ErrorHandlerDialog({super.key, this.error, this.stackTrace});

  final Object? error;
  final StackTrace? stackTrace;

  Future<void> showDialog(BuildContext context) {
    return showAdaptiveDialog(
      context: context,
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text(AppLocalizations.of(context).runtimeError),
      content: LogRow(
        LogEvent(
          'Runtime error',
          exception: error,
          stackTrace: stackTrace,
          level: Level.error,
        ),
      ),
      scrollable: true,
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(AppLocalizations.of(context).close),
        ),
        if (!SettingsManager.of(context).sentryEnabled.value)
          TextButton(
            onPressed: () {
              _logError();
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context).logSingleError),
          ),
        Link(
          uri: ApplicationSettingsPage.makeSettingsUri(
            ErrorReportingSettingsPage.routeName,
          ),
          builder: (context, followLink) => TextButton(
            onPressed: () {
              if (!SettingsManager.of(context).sentryEnabled.value) {
                _logError();
              }
              Navigator.of(context).pop();
              followLink?.call();
            },
            child: Text(
              SettingsManager.of(context).sentryEnabled.value
                  ? AppLocalizations.of(context).errorReporting
                  : AppLocalizations.of(context).enableSentry,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _logError() {
    return ErrorLogger().uploadError(error, stackTrace);
  }
}
