import 'package:flutter/material.dart';

import 'components/cancel_share_button.dart';
import 'components/share_files_text.dart';
import 'components/share_text.dart';

class SharingIntentBanner extends MaterialBanner {
  const SharingIntentBanner._({required super.content})
      : super(
          actions: const [CancelShareButton()],
        );

  factory SharingIntentBanner.files() {
    return const SharingIntentBanner._(content: ShareFilesText());
  }

  factory SharingIntentBanner.text() {
    return const SharingIntentBanner._(content: ShareText());
  }
}
