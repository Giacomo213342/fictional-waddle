import 'package:flutter/material.dart';

import 'package:unifiedpush/unifiedpush.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../utils/error_logger.dart';
import '../../../widgets/ascii_progress_indicator.dart';
import '../../../widgets/matrix/client_manager/client_manager.dart';
import '../../../widgets/settings_manager.dart';
import 'push/push_provider_radio_tile.dart';
import 'push/unified_push_unavailable.dart';

class PushSettingsPage extends StatefulWidget {
  const PushSettingsPage({super.key});

  static const routeName = 'push';

  @override
  State<PushSettingsPage> createState() => _PushSettingsPageState();
}

class _PushSettingsPageState extends State<PushSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).pushSettings),
      ),
      body: FutureBuilder(
        future: UnifiedPush.getDistributors(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: AsciiProgressIndicator(),
            );
          }
          if (data == null || data.isEmpty) {
            return const UnifiedPushUnavailable();
          }
          final isSingleProvider = data
                  .where(
                    (d) => !d.startsWith('business.braid.polycule'),
                  )
                  .length ==
              1;
          return ValueListenableBuilder(
            valueListenable: SettingsManager.of(context).pushDistributor,
            builder: (context, pushDistributor, _) => ListView.builder(
              itemCount: data.length + 1,
              itemBuilder: (context, index) {
                final distributor = data.elementAtOrNull(index);
                return PushProviderRadioTile(
                  distributor: distributor,
                  groupValue: pushDistributor,
                  onChanged: _setPushDistributor,
                  isSingleProvider: isSingleProvider,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _setPushDistributor(String? value) async {
    final oldValue = SettingsManager.of(context).pushDistributor.value;
    SettingsManager.of(context).pushDistributor.value = value;
    try {
      if (value == null) {
        for (final pushManager in ClientManager.pushManagers.values) {
          await pushManager.unregister();
        }
        return;
      }
      await UnifiedPush.saveDistributor(value);
      for (final pushManager in ClientManager.pushManagers.values) {
        await pushManager.register();
      }
    } catch (e, s) {
      ErrorLogger().captureStackTrace(e, s);
      if (!mounted) {
        return;
      }
      SettingsManager.of(context).pushDistributor.value = oldValue;
    }
  }
}
