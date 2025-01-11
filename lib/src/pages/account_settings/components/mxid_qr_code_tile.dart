import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:matrix/matrix.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../utils/matrix_to_extension.dart';
import '../../../widgets/share_origin_builder.dart';
import '../account_settings.dart';

class MxidQRCodeTile extends StatelessWidget {
  const MxidQRCodeTile(this.controller, {super.key});

  final AccountSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final userId = controller.client.userID!;
    final link = MatrixIdentifierStringExtensionResults(
      primaryIdentifier: userId,
    ).toMatrixToUrl();
    return Center(
      child: SizedBox.square(
        dimension: 192,
        child: ShareOriginBuilder(
          builder: (context, rect) {
            return Card(
              child: InkWell(
                onTap: () => !kIsWeb && (Platform.isAndroid || Platform.isIOS)
                    ? Share.shareUri(
                        Uri.parse(link),
                        sharePositionOrigin: rect,
                      )
                    : Share.share(
                        link,
                        subject: AppLocalizations.of(context)
                            .matrixUserShareSubject(userId),
                        sharePositionOrigin: rect,
                      ),
                child: BarcodeWidget(
                  padding: const EdgeInsets.all(8),
                  barcode: Barcode.qrCode(),
                  color: DefaultTextStyle.of(context).style.color ??
                      Theme.of(context).colorScheme.onSurface,
                  data: link,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
