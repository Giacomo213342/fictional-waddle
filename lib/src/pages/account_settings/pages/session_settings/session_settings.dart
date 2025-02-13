import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../widgets/ascii_progress_indicator.dart';
import '../../../../widgets/matrix/scopes/client_scope.dart';
import '../../../../widgets/matrix/scopes/device_scope.dart';
import 'components/oidc_sessions_idp_link.dart';
import 'components/session_tile.dart';

class SessionSettingsPage extends StatefulWidget {
  const SessionSettingsPage({super.key});

  static const routeName = 'sessions';

  @override
  State<SessionSettingsPage> createState() => _SessionSettingsPageState();
}

class _SessionSettingsPageState extends State<SessionSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).manageSessions),
        actions: OidcSessionsIdpLink.ifSupported(context),
      ),
      body: StreamBuilder<SyncUpdate>(
        stream:
            client.onSync.stream.where((update) => update.deviceLists != null),
        builder: (context, _) => FutureBuilder(
          future: client.getDevices(),
          builder: (context, snapshot) {
            final devices = snapshot.data;
            if (devices == null) {
              return const Center(
                child: AsciiProgressIndicator(),
              );
            }
            devices.sort((a, b) {
              final aLastSeen = a.lastSeenTs;
              final bLastSeen = b.lastSeenTs;
              if (aLastSeen == null || bLastSeen == null) {
                return 0;
              }
              return bLastSeen.compareTo(aLastSeen);
            });
            return ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) => DeviceScope(
                device: devices[index],
                child: SessionTile(
                  key: ValueKey(devices[index].deviceId),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
