import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../l10n/matrix/polycule_matrix_localizations.dart';
import '../../../../utils/matrix/oauth2_redirect_uri_extension.dart';
import '../../../../utils/matrix/oidc_delegation_extension.dart';
import '../../../../widgets/ascii_progress_indicator.dart';
import '../../../../widgets/intent_manager.dart';
import '../../../../widgets/matrix/scopes/client_scope.dart';
import '../linux_oauth2_hint.dart';

class MatrixOidcLoginProvider extends StatefulWidget {
  const MatrixOidcLoginProvider({
    super.key,
    this.discoveryInformation,
  });

  final DiscoveryInformation? discoveryInformation;

  @override
  State<MatrixOidcLoginProvider> createState() =>
      _MatrixOidcLoginProviderState();
}

class _MatrixOidcLoginProviderState extends State<MatrixOidcLoginProvider> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          AppLocalizations.of(context).loginOidc,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 16),
        Center(
          child: FloatingActionButton.extended(
            enableFeedback: _loading,
            onPressed: _loading ? null : _connectOidc,
            icon: _loading
                ? const AsciiProgressIndicator()
                : const Icon(Icons.login),
            label: Text(AppLocalizations.of(context).connect),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 150),
            child: SizedBox(
              height: _loading ? null : 0,
              child: ClipRect(
                clipBehavior: Clip.hardEdge,
                child: OverflowBox(
                  fit: OverflowBoxFit.deferToChild,
                  child: TextButton.icon(
                    onPressed: _cancel,
                    icon: const Icon(Icons.cancel),
                    label: Text(AppLocalizations.of(context).cancel),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!kIsWeb && Platform.isLinux) LinuxOAuth2Hint(expanded: _loading),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _connectOidc() async {
    setState(() {
      _loading = true;
    });
    try {
      final client = ClientScope.of(context).client;

      final name = AppLocalizations.of(context).initialDeviceDisplayName;

      final oidcClientId = await client.oidcEnsureDynamicClientId(
        await PolyculeOidcDynamicClientRegistrationData.fromAppLocalizations(),
      );
      if (oidcClientId == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      final nativeCompleter = IntentManager.oidcCallbackCompleter =
          Completer<OidcCallbackResponse>();
      await client.oidcLoginAuthorizationGrantFlow(
        nativeCompleter: nativeCompleter,
        oidcClientId: oidcClientId,
        redirectUri: client.oAuth2RedirectUri,
        launchOAuth2Uri: launchUrl,
        responseMode: kIsWeb ? 'fragment' : 'query',
        prompt: 'consent',
        initialDeviceDisplayName: name,
        enforceNewDeviceId: true,
      );
      IntentManager.oidcCallbackCompleter = null;
    } catch (e, s) {
      Logs().e('Error during OIDC login.', e, s);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });
  }

  void _cancel() {
    IntentManager.oidcCallbackCompleter?.completeError(
      Exception('Canceled by user'),
    );
    IntentManager.oidcCallbackCompleter = null;

    setState(() {
      _loading = false;
    });
  }
}
