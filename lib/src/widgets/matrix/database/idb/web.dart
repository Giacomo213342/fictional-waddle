// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';
import 'dart:js_util';

dynamic createIdbFactory() {
  return getProperty(window, 'indexedDB');
}

Future<bool> persistStorage() async {
  return await window.navigator.storage?.persist() ?? false;
}
