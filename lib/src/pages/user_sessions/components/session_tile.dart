import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../theme/colors/poly_pride.dart';
import '../../../theme/fonts.dart';
import '../../../widgets/human_date.dart';
import '../../../widgets/matrix/scopes/session_scope.dart';
import '../../../widgets/matrix/verify_device_button.dart';
import '../../../widgets/polycule_overflow_bar.dart';
import 'block_session_button.dart';

class SessionTile extends StatelessWidget {
  const SessionTile({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceKeys = SessionScope.of(context).session;
    final deviceId = deviceKeys.deviceId;
    return ExpansionTile(
      leading: deviceKeys.directVerified
          ? const Icon(
              Icons.shield,
              color: Colors.green,
            )
          : deviceKeys.verified
              ? const Icon(
                  Icons.enhanced_encryption,
                  color: PolyColors.cyan,
                )
              : deviceKeys.blocked
                  ? Icon(
                      Icons.no_encryption,
                      color: Theme.of(context).colorScheme.error,
                    )
                  : const Icon(Icons.devices),
      title: Text(
        deviceKeys.deviceDisplayName ??
            deviceKeys.deviceId ??
            deviceKeys.userId,
      ),
      children: [
        if (deviceId != null)
          ListTile(
            leading: Tooltip(
              message: AppLocalizations.of(context).sessionId,
              child: const Icon(Icons.numbers),
            ),
            title: SelectableText(
              deviceId,
              style: TextStyle(fontFamily: PolyculeFonts.notoSansMono.name),
            ),
          ),
        ListTile(
          leading: Tooltip(
            message: AppLocalizations.of(context).sessionLastSeen,
            child: const Icon(Icons.history),
          ),
          title: Text(
            deviceKeys.lastActive.humanShortDate(context: context),
          ),
        ),
        const PolyculeOverflowBar(
          children: [
            BlockSessionButton(),
            VerifyDeviceButton(),
          ],
        ),
      ],
    );
  }
}
