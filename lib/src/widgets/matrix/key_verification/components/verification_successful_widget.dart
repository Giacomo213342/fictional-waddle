import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../key_verification_request_widget.dart';

class VerificationSuccessfulWidget extends StatelessWidget {
  const VerificationSuccessfulWidget({
    super.key,
    this.onClose,
    required this.buttonBarBuilder,
  });

  final VoidCallback? onClose;
  final ButtonBarBuilder buttonBarBuilder;

  @override
  Widget build(BuildContext context) {
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
                    Icons.check_circle,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    AppLocalizations.of(context).verificationSuccessful,
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
