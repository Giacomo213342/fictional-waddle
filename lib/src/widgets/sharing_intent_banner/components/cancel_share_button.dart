import 'package:flutter/material.dart';

import '../../matrix/client_manager/client_manager.dart';

class CancelShareButton extends StatefulWidget {
  const CancelShareButton({super.key});

  @override
  State<CancelShareButton> createState() => _CancelShareButtonState();
}

class _CancelShareButtonState extends State<CancelShareButton> {
  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: _cancelShare,
        icon: const Icon(Icons.cancel),
        tooltip: MaterialLocalizations.of(context).cancelButtonLabel,
      );

  void _cancelShare() {
    ClientManager.claimShareIntent();
    ScaffoldMessenger.of(context).clearMaterialBanners();
  }
}
