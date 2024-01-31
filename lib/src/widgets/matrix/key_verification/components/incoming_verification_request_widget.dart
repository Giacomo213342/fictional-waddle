import 'package:flutter/material.dart';

import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../key_verification_request_widget.dart';
import 'incoming_verifcation_request_content.dart';

class IncomingVerificationRequestWidget extends StatelessWidget {
  const IncomingVerificationRequestWidget(
    this.request, {
    super.key,
    this.profile,
    this.onReject,
    this.onAccept,
    required this.buttonBarBuilder,
    required this.client,
  });

  final KeyVerification request;
  final Profile? profile;
  final ButtonBarBuilder buttonBarBuilder;
  final VoidCallback? onReject;
  final VoidCallback? onAccept;
  final Client? client;

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.security,
                    size: 32,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: Text(
                    AppLocalizations.of(context).incomingVerificationRequest,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                const SizedBox(height: 8),
                IncomingVerificationRequestContentWidget(
                  client: client,
                  profile: profile,
                ),
              ],
            ),
          ),
          buttonBarBuilder.call(
            context,
            [
              ElevatedButton(
                onPressed: onReject?.call,
                child: Text(AppLocalizations.of(context).reject),
              ),
              ElevatedButton(
                onPressed: onAccept?.call,
                child: Text(AppLocalizations.of(context).proceed),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
