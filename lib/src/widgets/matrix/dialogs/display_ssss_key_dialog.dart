import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../pages/ssss_bootstrap/ssss_bootstrap.dart';
import '../../../utils/secure_storage.dart';
import '../../polycule_highlight_view.dart';
import '../../polycule_overflow_bar.dart';
import '../scopes/client_scope.dart';
import '../scopes/matrix_scope.dart';

class DisplaySSSSKeyDialog extends StatelessWidget {
  const DisplaySSSSKeyDialog({super.key});

  Future<void> show(BuildContext context) async {
    final scope = MatrixScope.captureAll(context);
    return await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) => MatrixScope(scope: scope, child: this),
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    return FutureBuilder(
      future: kPolyculeSecureStorage.read(
        key: SsssBootstrapController.ssssKeyStorage(client),
      ),
      builder: (context, snapshot) {
        final ssss =
            snapshot.data ?? List.generate(12, (_) => 'XXXX').join(' ');
        return ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                AppLocalizations.of(context).ssssRecoveryKey,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child:
                  Text(AppLocalizations.of(context).ssssRecoveryKeyExplanation),
            ),
            const SizedBox(height: 16),
            PolyculeHighlightView(ssss),
            const SizedBox(height: 16),
            PolyculeOverflowBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: Navigator.of(context).pop,
                  child:
                      Text(MaterialLocalizations.of(context).backButtonTooltip),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      kPolyculeSecureStorage.delete(
                        key: SsssBootstrapController.ssssKeyStorage(client),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child:
                      Text(AppLocalizations.of(context).confirmSSSSKeyStored),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
