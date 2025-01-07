// ignore_for_file:implementation_imports

import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/settings_manager.dart';

class NetworkSettingsPage extends StatefulWidget {
  const NetworkSettingsPage({super.key});

  static const routeName = 'network';

  @override
  State<NetworkSettingsPage> createState() => _NetworkSettingsPageState();
}

class _NetworkSettingsPageState extends State<NetworkSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).networkSettings),
      ),
      body: ValueListenableBuilder<NetworkState>(
        valueListenable: SettingsManager.of(context).network,
        builder: (context, networkState, _) {
          return ListView(
            children: [
              SwitchListTile.adaptive(
                // const Icon(Icons.perm_identity),

                title: Text(AppLocalizations.of(context).useSystemProxy),
                value: networkState.permitProxy,
                onChanged: _setProxy,
              ),
              SwitchListTile.adaptive(
                // const Icon(Icons.perm_identity),

                title: Text(AppLocalizations.of(context).verifyCertificates),
                value: networkState.verifyCertificates,
                onChanged: _setVerifyCertificates,
              ),
              SwitchListTile.adaptive(
                // const Icon(Icons.perm_identity),

                title: Text(AppLocalizations.of(context).sendTlsSNI),
                value: networkState.useSni,
                onChanged: _setSni,
              ),
              ListTile(
                leading: const Icon(Icons.vpn_lock),
                title: Text(AppLocalizations.of(context).minTlsVersion),
              ),
              RadioListTile.adaptive(
                value: 0x0303,
                groupValue: networkState.tlsMinVersion,
                title: Text(AppLocalizations.of(context).tls12),
                onChanged: _setTlsMinVersion,
              ),
              RadioListTile.adaptive(
                value: 0x0304,
                groupValue: networkState.tlsMinVersion,
                title: Text(AppLocalizations.of(context).tls13),
                onChanged: _setTlsMinVersion,
              ),
            ],
          );
        },
      ),
    );
  }

  void _setProxy(bool? permitProxy) {
    if (permitProxy == null) {
      return;
    }

    SettingsManager.of(context).network.value = SettingsManager.of(context)
        .network
        .value
        .copyWith(permitProxy: permitProxy);
  }

  void _setVerifyCertificates(bool? verifyCertificates) {
    if (verifyCertificates == null) {
      return;
    }

    SettingsManager.of(context).network.value = SettingsManager.of(context)
        .network
        .value
        .copyWith(verifyCertificates: verifyCertificates);
  }

  void _setSni(bool? useSni) {
    if (useSni == null) {
      return;
    }

    SettingsManager.of(context).network.value =
        SettingsManager.of(context).network.value.copyWith(useSni: useSni);
  }

  void _setTlsMinVersion(int? tlsMinVersion) {
    if (tlsMinVersion == null) {
      return;
    }

    SettingsManager.of(context).network.value = SettingsManager.of(context)
        .network
        .value
        .copyWith(tlsMinVersion: tlsMinVersion);
  }
}
