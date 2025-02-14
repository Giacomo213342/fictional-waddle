import 'package:flutter/material.dart';

import '../../intent_manager.dart';

class CancelShareButton extends StatefulWidget {
  const CancelShareButton({super.key});

  @override
  State<CancelShareButton> createState() => _CancelShareButtonState();
}

class _CancelShareButtonState extends State<CancelShareButton> {
  @override
  void initState() {
    IntentManager.sharedFilesListener.addListener(_clearBanner);
    IntentManager.sharedTextListener.addListener(_clearBanner);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: _cancelShare,
        icon: const Icon(Icons.cancel),
        tooltip: MaterialLocalizations.of(context).cancelButtonLabel,
      );

  @override
  void dispose() {
    IntentManager.sharedFilesListener.removeListener(_clearBanner);
    IntentManager.sharedTextListener.removeListener(_clearBanner);
    super.dispose();
  }

  Future<void> _cancelShare() async {
    await IntentManager.claimShareIntent();
    _clearBanner();
  }

  void _clearBanner() {
    if (IntentManager.sharedFilesListener.value != null ||
        IntentManager.sharedTextListener.value != null) {
      return;
    }
    ScaffoldMessenger.of(context).clearMaterialBanners();
  }
}
