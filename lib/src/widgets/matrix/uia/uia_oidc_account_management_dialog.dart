import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:oidc/oidc.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../utils/matrix/oidc_delegation_extension.dart';
import '../../ascii_progress_indicator.dart';
import '../matrix_scope.dart';

class UiaOidcAccountManagementDialog extends StatefulWidget {
  const UiaOidcAccountManagementDialog({
    super.key,
    required this.request,
    required this.client,
    required this.oidc,
    required this.action,
  });

  final UiaRequest request;
  final Client client;
  final OidcUserManager oidc;
  final OidcAccountManagementActions action;

  Future<bool?> show(BuildContext context) {
    final scope = MatrixScope.captureAll(context);
    return showAdaptiveDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MatrixScope(
        scope: scope,
        child: this,
      ),
    );
  }

  @override
  State<UiaOidcAccountManagementDialog> createState() =>
      _UiaOidcAccountManagementDialogState();
}

class _UiaOidcAccountManagementDialogState
    extends State<UiaOidcAccountManagementDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final userId = widget.client.userID;
    return AlertDialog.adaptive(
      title: Text(AppLocalizations.of(context).authenticationRequired),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 256 + 128),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (userId != null) ...[
              Text(AppLocalizations.of(context).authenticateForAccount(userId)),
              const SizedBox(height: 16),
            ],
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton.extended(
                enableFeedback: _loading,
                onPressed: _loading ? null : _accountManagementDeeplink,
                icon: _loading
                    ? const AsciiProgressIndicator()
                    : const Icon(Icons.security),
                label: Text(AppLocalizations.of(context).oidcConfirm),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(AppLocalizations.of(context).submit),
        ),
      ],
    );
  }

  Future<void> _accountManagementDeeplink() async {
    setState(() {
      _loading = true;
    });

    try {
      await widget.client.oidcAccountManagement(
        action: widget.action,
        deviceId: widget.client.deviceID,
      );

      setState(() {
        _loading = false;
      });

      if (!mounted) {
        return;
      }
    } catch (_) {
      setState(() {
        _loading = false;
      });
      rethrow;
    }
  }
}
