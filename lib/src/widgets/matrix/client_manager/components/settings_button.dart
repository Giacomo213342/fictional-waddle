import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../client_manager.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key, required this.manager});

  final ClientManager manager;

  @override
  Widget build(BuildContext context) {
    final isActive = manager.widget.activeClientIdentifier == null;
    return SizedBox.square(
      dimension: 48,
      child: Padding(
        padding: isActive ? const EdgeInsets.all(2.0) : EdgeInsets.zero,
        child: Material(
          elevation: isActive ? 2 : 0,
          borderRadius: BorderRadius.circular(24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: .25)
                    : Colors.transparent,
                border: isActive
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                tooltip: AppLocalizations.of(context).settings,
                onPressed: manager.openSettings,
                icon: const Icon(Icons.settings),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
