import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../future_callback_builder.dart';
import 'qr_dialog.dart';

class QrScanTile extends StatelessWidget {
  const QrScanTile({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: FutureCallbackBuilder(
            callback: () => const QrDialog().show(context),
            builder: (context, callback, _) => FilledButton.icon(
              onPressed: callback,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(AppLocalizations.of(context).scanQrCode),
            ),
          ),
        ),
      );
}
