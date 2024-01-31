import 'package:flutter/material.dart';

import 'package:matrix/encryption.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../key_verification_request_widget.dart';

class VerificationRequestErrorWidget extends StatelessWidget {
  const VerificationRequestErrorWidget(
    this.request, {
    super.key,
    this.onClose,
    required this.buttonBarBuilder,
  });

  final KeyVerification request;
  final ButtonBarBuilder buttonBarBuilder;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    String message;
    // TODO: handle request.cancelCode and request.cancelReason
    switch (request.canceledCode) {
      case 'm.user':
        message = AppLocalizations.of(context).keyVerificationErrorUser;
        break;
      default:
        message = AppLocalizations.of(context).keyVerificationErrorGeneric;
        break;
    }
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.cancel,
                    color: Theme.of(context).colorScheme.error,
                    size: 32,
                  ),
                  title: Text(
                    message,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
          buttonBarBuilder.call(
            context,
            [
              ElevatedButton(
                onPressed: onClose?.call,
                child: Text(AppLocalizations.of(context).close),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
