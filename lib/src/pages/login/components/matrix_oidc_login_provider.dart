import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/ascii_progress_indicator.dart';
import '../../../widgets/matrix/client_manager/client_manager.dart';
import '../../../widgets/matrix/client_scope.dart';
import '../login.dart';

class MatrixOidcLoginProvider extends StatefulWidget {
  const MatrixOidcLoginProvider(
    this.controller, {
    super.key,
    this.discoveryInformation,
  });

  final LoginController controller;
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
        const SizedBox(height: 32),
      ],
    );
  }

  Future<void> _connectOidc() async {
    setState(() {
      _loading = true;
    });
    try {
      final client = ClientScope.of(context).client;
      final appName = AppLocalizations.of(context).appName;
      final manager = await ClientManager.buildOidcManager(
        client,
        [AppLocalizations.of(context).localeName],
        // TODO: dehydrated devices ?
        enforceNewDevice: true,
      );
      if (manager == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      final user = await manager.loginAuthorizationCodeFlow(
        originalUri: Uri.parse('about:blank'),
      );

      final token = user?.token;
      if (user == null || token == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      DateTime? expiresAt;

      final expiresIn = token.expiresIn;
      if (expiresIn != null) {
        expiresAt = DateTime.now().add(expiresIn);
      }

      // workaround missing user ID in token
      client.bearerToken = token.accessToken;
      final tokenInfo = await client.getTokenOwner();
      client.bearerToken = null;

      await client.init(
        newToken: token.accessToken,
        newTokenExpiresAt: expiresAt,
        newRefreshToken: token.refreshToken,
        newUserID: tokenInfo.userId,
        newHomeserver: client.homeserver,
        newDeviceName: appName,
        newDeviceID: tokenInfo.deviceId,
      );
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
}
