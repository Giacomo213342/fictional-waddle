import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/matrix/key_trust_icon_theme.dart';
import '../../../../../widgets/matrix/scopes/client_scope.dart';
import '../../../../../widgets/matrix/scopes/device_scope.dart';

class KeyTrustTile extends StatelessWidget {
  const KeyTrustTile({super.key});

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    final device = DeviceScope.of(context).device;

    final deviceKeys =
        client.userDeviceKeys[client.userID]?.deviceKeys[device.deviceId];

    if (deviceKeys == null) {
      return const _NoEncryptionDevice();
    }
    if (deviceKeys.blocked) {
      return const _BlockedDevice();
    }
    if (deviceKeys.verified) {
      return const _VerifiedDevice();
    }
    return const _UnverifiedDevice();
  }
}

class _NoEncryptionDevice extends StatelessWidget {
  const _NoEncryptionDevice();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const KeyTrustIconTheme(child: Icon(Icons.key_off)),
      title: Text(AppLocalizations.of(context).deviceNoEncryption),
    );
  }
}

class _UnverifiedDevice extends StatelessWidget {
  const _UnverifiedDevice();

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    final device = DeviceScope.of(context).device;
    final isOwnDevice = client.userDeviceKeys[client.userID]?.deviceKeys
        .containsKey(device.deviceId);

    return ListTile(
      leading: KeyTrustIconTheme(
        child: Icon(isOwnDevice == true ? Icons.error : Icons.question_mark),
      ),
      title: Text(AppLocalizations.of(context).deviceUnverified),
    );
  }
}

class _VerifiedDevice extends StatelessWidget {
  const _VerifiedDevice();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const KeyTrustIconTheme(child: Icon(Icons.verified_user)),
      title: Text(AppLocalizations.of(context).deviceVerified),
    );
  }
}

class _BlockedDevice extends StatelessWidget {
  const _BlockedDevice();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const KeyTrustIconTheme(child: Icon(Icons.block)),
      title: Text(AppLocalizations.of(context).deviceBlocked),
    );
  }
}
