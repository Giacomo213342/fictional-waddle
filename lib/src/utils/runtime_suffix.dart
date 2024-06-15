import 'dart:io';

import 'package:flutter/foundation.dart';

String getRuntimeSuffix() {
  if (kIsWeb) {
    return '';
  }

  final addDebugSuffix = kDebugMode && (Platform.isLinux);
  final addProfileSuffix = kProfileMode &&
      (Platform.isLinux ||
          Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isMacOS);

  return addDebugSuffix
      ? '-debug'
      : addProfileSuffix
          ? '-profile'
          : '';
}
