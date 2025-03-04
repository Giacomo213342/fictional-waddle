import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/matrix/polycule_matrix_localizations.dart';
import '../../../utils/matrix/legacy_idp_extension.dart';
import '../../../utils/matrix/oauth2_redirect_uri_extension.dart';
import '../../../widgets/device_pixel_ratio_builder.dart';
import '../../../widgets/intent_manager.dart';
import '../../../widgets/matrix/scopes/client_scope.dart';

class LegacyIdpButton extends StatefulWidget {
  const LegacyIdpButton({super.key, required this.idp});

  final LegacyIdp idp;

  @override
  State<LegacyIdpButton> createState() => _LegacyIdpButtonState();
}

class _LegacyIdpButtonState extends State<LegacyIdpButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    final label = widget.idp.name;
    final icon = widget.idp.icon;

    // synapse seems to like returning the icons with a white background
    final theme = FilledButton.styleFrom(
      backgroundColor: Colors.white,
    );

    return _loading
        ? FilledButton.icon(
            style: theme,
            onPressed: _cancel,
            icon: const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(),
            ),
            label: Text(AppLocalizations.of(context).cancel),
          )
        : icon == null
            ? FilledButton(
                onPressed: _login,
                style: theme,
                child: Text(label),
              )
            : FilledButton.icon(
                onPressed: _login,
                style: theme,
                icon: DevicePixelRatioBuilder(
                  builder: (context, ratio) {
                    final dimension = 24 * ratio;
                    return Image.network(
                      icon
                          // not logged in yet so no authenticated media
                          // ignore: deprecated_member_use
                          .getThumbnail(
                            client,
                            width: dimension,
                            height: dimension,
                          )
                          .toString(),
                      width: 24,
                      height: 24,
                    );
                  },
                ),
                label: Text(label),
              );
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
    });
    try {
      final client = ClientScope.of(context).client;
      final deviceDisplayName =
          AppLocalizations.of(context).initialDeviceDisplayName;
      final uri = client.homeserver?.resolveUri(
        Uri.parse(
          '/_matrix/client/v3/login/sso/redirect/${widget.idp.id}?redirectUrl=${client.oAuth2RedirectUri}',
        ),
      );
      if (uri == null) {
        return;
      }

      final nativeCompleter =
          IntentManager.legacySsoCallbackCompleter = Completer<String>();
      await launchUrl(uri);
      final response = await nativeCompleter.future;

      IntentManager.oidcCallbackCompleter = null;

      await client.login(
        AuthenticationTypes.token,
        token: response,
        initialDeviceDisplayName: deviceDisplayName,
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
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
