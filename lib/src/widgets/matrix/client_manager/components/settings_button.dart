import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../pages/application_settings/application_settings.dart';
import '../../../../router/extensions/go_router_path_extension.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isActive = GoRouterState.of(context).clientIdentifier == null;
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
                onPressed: () =>
                    context.push(ApplicationSettingsPage.routeName),
                icon: const Icon(Icons.settings),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
