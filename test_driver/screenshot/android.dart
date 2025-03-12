// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';

Future<Uint8List> screenshotAndroid(String screenshotName) async {
  final pwd = Directory('/tmp/polycule-driver');
  if (!await pwd.exists()) {
    await pwd.create();
  }
  print('[android driver] Pulling screenshot from internal storage ...');
  print('[android driver] adb pull $screenshotName');

  final file = File('${pwd.path}/${screenshotName.split('/').last}');
  if (await file.exists()) {
    await file.delete();
  }
  await Process.run(
    'adb',
    'pull $screenshotName'.split(' '),
    stdoutEncoding: null,
    workingDirectory: pwd.path,
  );
  final bytes = await file.readAsBytes();
  await file.delete();

  print('[android driver] Done.');
  return bytes;
}
