import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:matrix/matrix.dart';

import '../../../scopes/matrix_scope.dart';

class QrDialog extends StatelessWidget {
  const QrDialog({super.key});

  Future<void> show(BuildContext context) async {
    final scope = MatrixScope.captureAll(context);
    final verification = scope.verification;
    final result =
        await Navigator.of(context, rootNavigator: true).push<Uint8List?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => MatrixScope(scope: scope, child: this),
      ),
    );
    if (result == null) {
      return;
    }
    await verification?.continueVerification(
      EventTypes.Reciprocate,
      qrDataRawBytes: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: ReaderWidget(
        onScan: (code) => Navigator.of(context).pop(code.rawBytes),
        codeFormat: Format.qrCode,
        showGallery: false,
        showFlashlight: false,
        showToggleCamera: false,
        tryInverted: true,
        showScannerOverlay: true,
      ),
    );
  }
}
