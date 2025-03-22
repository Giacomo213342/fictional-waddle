import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/future_callback_builder.dart';
import '../../../widgets/matrix/scopes/session_scope.dart';

class BlockSessionButton extends StatelessWidget {
  const BlockSessionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context).session;
    return FutureCallbackBuilder(
      callback: () => session.setBlocked(!session.blocked),
      builder: (context, callback, _, __) => TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
        onPressed: callback,
        child: Text(
          session.blocked
              ? AppLocalizations.of(context).unblock
              : AppLocalizations.of(context).block,
        ),
      ),
    );
  }
}
