import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:barcode_widget/barcode_widget.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../scopes/sas_scope.dart';

class QrShow extends StatelessWidget {
  const QrShow({super.key});

  @override
  Widget build(BuildContext context) {
    final verification = SasScope.of(context).verification;
    final qr = verification.qrCode;
    if (qr == null) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            child: Card(
              child: SizedBox.square(
                dimension: 256,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BarcodeWidget.fromBytes(
                    data: Uint8List.fromList(qr.qrDataRawBytes),
                    barcode: Barcode.qrCode(),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          Text(
            AppLocalizations.of(context).scanQrWithOtherDevice,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
