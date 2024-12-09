import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:oidc/oidc.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../ascii_progress_indicator.dart';

class UiaOidcDialog extends StatefulWidget {
  const UiaOidcDialog({
    super.key,
    required this.request,
    required this.client,
    required this.oidc,
  });

  final UiaRequest request;
  final Client client;
  final OidcUserManager oidc;

  Future<OidcUser?> show(BuildContext context) => showDialog<OidcUser?>(
        context: context,
        barrierDismissible: false,
        builder: (context) => this,
      );

  @override
  State<UiaOidcDialog> createState() => _UiaOidcDialogState();
}

class _UiaOidcDialogState extends State<UiaOidcDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final userId = widget.client.userID;
    return AlertDialog(
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
                onPressed: _loading ? null : _oidcAuthenticate,
                icon: _loading
                    ? const AsciiProgressIndicator()
                    : const Icon(Icons.login),
                label: Text(AppLocalizations.of(context).connect),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(AppLocalizations.of(context).cancel),
        ),
      ],
    );
  }

  Future<void> _oidcAuthenticate() async {
    setState(() {
      _loading = true;
    });

    try {
      final user = await widget.oidc.loginAuthorizationCodeFlow(
        originalUri: Uri.parse('about:blank'),
      );

      setState(() {
        _loading = false;
      });

      if (user == null || !mounted) {
        return;
      }

      Navigator.of(context).pop(user);
    } catch (_) {
      setState(() {
        _loading = false;
      });
      rethrow;
    }
  }
}
