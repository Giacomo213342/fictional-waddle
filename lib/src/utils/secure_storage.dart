import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const kPolyculeSecureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
  iOptions: IOSOptions(groupId: 'group.business.braid.polycule'),
  mOptions: MacOsOptions(groupId: 'group.business.braid.polycule'),
  lOptions: LinuxOptions(),
  webOptions: WebOptions(),
  wOptions: WindowsOptions(),
);
