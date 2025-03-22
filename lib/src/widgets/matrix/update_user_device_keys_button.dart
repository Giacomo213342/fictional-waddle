import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../ascii_progress_indicator.dart';
import '../future_callback_builder.dart';
import 'scopes/client_scope.dart';
import 'scopes/matrix_identifier_scope.dart';

class UpdateUserDeviceKeysButton extends StatelessWidget {
  const UpdateUserDeviceKeysButton({super.key});

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    final identifier = MatrixIdentifierScope.maybeOf(context)?.identifier;
    return FutureCallbackBuilder(
      callback: () => client.updateUserDeviceKeys(
        additionalUsers:
            identifier != null ? {identifier.primaryIdentifier} : null,
      ),
      builder: (context, callback, loading, _) => loading
          ? const SizedBox.square(
              dimension: 24,
              child: AsciiProgressIndicator(),
            )
          : IconButton(
              onPressed: callback,
              icon: const Icon(Icons.refresh),
              tooltip: AppLocalizations.of(context).reload,
            ),
    );
  }
}
