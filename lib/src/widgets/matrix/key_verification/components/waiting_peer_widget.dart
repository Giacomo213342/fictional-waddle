import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../ascii_progress_indicator.dart';
import '../../avatar_builder/mxc_avatar.dart';
import '../key_verification_request_widget.dart';

class WaitingPeerWidget extends StatelessWidget {
  const WaitingPeerWidget(
    this.profile, {
    super.key,
    this.onCancel,
    required this.buttonBarBuilder,
    required this.client,
  });

  final Client? client;
  final Profile? profile;
  final ButtonBarBuilder buttonBarBuilder;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    final client = this.client;
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
                const SizedBox(height: 16),
                if (profile != null && client != null)
                  MxcAvatar(
                    uri: profile.avatarUrl,
                    client: client,
                    monogram: profile.displayName ?? profile.userId,
                    dimension: 64,
                  ),
                const SizedBox(height: 16),
                const AsciiProgressIndicator(),
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
