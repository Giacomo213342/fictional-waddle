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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).networkSettings),
        ),
        body: ValueListenableBuilder<NetworkState>(
          valueListenable: SettingsManager.of(context).network,
          builder: (context, networkState, _) => RadioGroup<int>(
            groupValue: networkState.tlsMinVersion,
            onChanged: _setTlsMinVersion,
            child: ListView(
              children: [
                SwitchListTile.adaptive(
                  title: Text(AppLocalizations.of(context).useSystemProxy),
                  value: networkState.permitProxy,
                  onChanged: _setProxy,
                ),
                SwitchListTile.adaptive(
                  title: const Text('Use SOCKS5 Proxy'),
                  value: networkState.useSocks5Proxy,
                  onChanged: _setSocks5Proxy,
                ),
                if (networkState.useSocks5Proxy) ...[
                  ListTile(
                    title: TextFormField(
                      decoration: const InputDecoration(labelText: 'Proxy Host'),
                      initialValue: networkState.proxyHost,
                      onChanged: _setProxyHost,
                    ),
                  ),
                  ListTile(
                    title: TextFormField(
                      decoration: const InputDecoration(labelText: 'Proxy Port'),
                      initialValue: networkState.proxyPort?.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: _setProxyPort,
                    ),
                  ),
                  ListTile(
                    title: TextFormField(
                      decoration: const InputDecoration(labelText: 'Proxy Username'),
                      initialValue: networkState.proxyUsername,
                      onChanged: _setProxyUsername,
                    ),
                  ),
                  ListTile(
                    title: TextFormField(
                      decoration: const InputDecoration(labelText: 'Proxy Password'),
                      initialValue: networkState.proxyPassword,
                      obscureText: true,
                      onChanged: _setProxyPassword,
                    ),
                  ),
                ],
                SwitchListTile.adaptive(
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
                  title: Text(AppLocalizations.of(context).tls12),
                ),
                RadioListTile.adaptive(
                  value: 0x0304,
                  title: Text(AppLocalizations.of(context).tls13),
                ),
              ],
            ),
          ),
        ),
      );

  void _setProxy(bool? permitProxy) {
    if (permitProxy == null) {
      return;
    }

    SettingsManager.of(context).network.value = SettingsManager.of(context)
        .network
        .value
        .copyWith(permitProxy: permitProxy);
  }

  void _setSocks5Proxy(bool? useSocks5Proxy) {
    if (useSocks5Proxy == null) return;
    SettingsManager.of(context).network.value =
        SettingsManager.of(context).network.value.copyWith(useSocks5Proxy: useSocks5Proxy);
  }

  void _setProxyHost(String value) {
    SettingsManager.of(context).network.value =
        SettingsManager.of(context).network.value.copyWith(proxyHost: value);
  }

  void _setProxyPort(String value) {
    SettingsManager.of(context).network.value =
        SettingsManager.of(context).network.value.copyWith(proxyPort: int.tryParse(value));
  }

  void _setProxyUsername(String value) {
    SettingsManager.of(context).network.value =
        SettingsManager.of(context).network.value.copyWith(proxyUsername: value);
  }

  void _setProxyPassword(String value) {
    SettingsManager.of(context).network.value =
        SettingsManager.of(context).network.value.copyWith(proxyPassword: value);
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
