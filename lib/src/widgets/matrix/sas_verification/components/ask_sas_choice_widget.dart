import 'package:flutter/material.dart';

import 'package:matrix/matrix_api_lite/model/event_types.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../ascii_progress_indicator.dart';
import '../../../future_callback_builder.dart';
import '../../../labeled_divider.dart';
import '../../scopes/sas_scope.dart';
import 'qr/qr_scan_tile.dart';
import 'qr/qr_show.dart';
import 'qr/sas_tile.dart';
import 'sas_profile.dart';
import 'sas_verification_bottom_bar.dart';

class AskSASChoiceWidget extends StatelessWidget {
  const AskSASChoiceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final verification = SasScope.of(context).verification;
    final List<Widget> methods = [];

    if (verification.possibleMethods.contains(EventTypes.QRShow)) {
      methods.add(const QrShow());
    }
    if (verification.possibleMethods.contains(EventTypes.QRScan)) {
      if (methods.isNotEmpty) {
        methods.add(
          const LabeledDivider(),
        );
      }
      methods.add(const QrScanTile());
    }
    if (verification.possibleMethods.contains(EventTypes.Sas)) {
      if (methods.isNotEmpty) {
        methods.add(
          const LabeledDivider(),
        );
      }
      methods.add(const SasTile());
    }
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(
            height: 16,
          ),
          const Center(child: SasProfile()),
          ...methods,
          SasVerificationBottomBar(
            children: [
              FutureCallbackBuilder(
                callback: () =>
                    SasScope.of(context).verification.cancel('m.user'),
                builder: (context, callback, loading, _) => loading
                    ? const AsciiProgressIndicator()
                    : FilledButton.tonal(
                        onPressed: callback,
                        child: Text(AppLocalizations.of(context).cancel),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
