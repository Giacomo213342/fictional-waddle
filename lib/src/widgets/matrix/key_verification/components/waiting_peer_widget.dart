import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../key_verification_request_widget.dart';

class WaitingPeerWidget extends StatelessWidget {
  const WaitingPeerWidget(
    this.profile, {
    super.key,
    this.onCancel,
    required this.buttonBarBuilder,
  });

  final Profile? profile;
  final ButtonBarBuilder buttonBarBuilder;
  final VoidCallback? onCancel;

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // if (profile != null)
                // TODO : show user picture here
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(
                    AppLocalizations.of(context).waitingForVerification,
                  ),
                ),
              ],
            ),
          ),
          buttonBarBuilder.call(
            context,
            [
              ElevatedButton(
                onPressed: onCancel?.call,
                child: Text(AppLocalizations.of(context).cancel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
