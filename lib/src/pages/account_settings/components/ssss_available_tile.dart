import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../../../utils/secure_storage.dart';
import '../../../widgets/matrix/dialogs/display_ssss_key_dialog.dart';
import '../../../widgets/matrix/scopes/client_scope.dart';
import '../../ssss_bootstrap/ssss_bootstrap.dart';

class SSSSAvailableTile extends StatefulWidget {
  const SSSSAvailableTile({super.key});

  @override
  State<SSSSAvailableTile> createState() => _SSSSAvailableTileState();
}

class _SSSSAvailableTileState extends State<SSSSAvailableTile> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkSSSS(),
      builder: (context, snapshot) => SwitchListTile(
        isThreeLine: true,
        title: Text(AppLocalizations.of(context).keyBackupAvailable),
        subtitle: Text(AppLocalizations.of(context).keyBackupExplanation),
        value: snapshot.data ?? false,
        onChanged: snapshot.data == true ||
                snapshot.connectionState != ConnectionState.done
            ? null
            : (_) => _setupSSSS(snapshot.data),
      ),
    );
  }

  Future<bool?> _checkSSSS() async {
    final client = ClientScope.of(context).client;
    if (await kPolyculeSecureStorage.containsKey(
      key: SsssBootstrapController.ssssKeyStorage(client),
    )) {
      // do not proceed if we still have the local SSSS cache
      return null;
    }

    return await client.encryption?.keyManager.isCached() == true &&
        await client.encryption?.crossSigning.isCached() == true &&
        !client.isUnknownSession;
  }

  Future<void> _setupSSSS(bool? ssssState) async {
    if (ssssState == true) {
      return;
    }

    if (ssssState == null) {
      await const DisplaySSSSKeyDialog().show(context);
      setState(() {});
      return;
    }

    await context.pushMultiClient('${SsssBootstrapPage.routeName}?disableSas');
    setState(() {});
    return;
  }
}
