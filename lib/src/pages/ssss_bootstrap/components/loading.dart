import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/ascii_progress_indicator.dart';

class BootstrapLoading extends StatelessWidget {
  const BootstrapLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AsciiProgressIndicator(),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).setupSSSSLoading),
        ],
      ),
    );
  }
}
