import 'package:flutter/material.dart';

import '../../matrix/client_manager/client_manager.dart';

class CancelShareButton extends StatefulWidget {
  const CancelShareButton({super.key});

  @override
  State<CancelShareButton> createState() => _CancelShareButtonState();
}

class _CancelShareButtonState extends State<CancelShareButton> {
  @override
  void initState() {
    ClientManager.sharedFilesListener.addListener(_clearBanner);
    ClientManager.sharedTextListener.addListener(_clearBanner);
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
    ClientManager.sharedFilesListener.removeListener(_clearBanner);
    ClientManager.sharedTextListener.removeListener(_clearBanner);
    super.dispose();
  }

  void _cancelShare() {
    ClientManager.claimShareIntent();
    _clearBanner();
  }

  void _clearBanner() {
    if (ClientManager.sharedFilesListener.value != null ||
        ClientManager.sharedTextListener.value != null) {
      return;
    }
    ScaffoldMessenger.of(context).clearMaterialBanners();
  }
}
