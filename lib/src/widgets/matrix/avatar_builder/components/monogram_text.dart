import 'dart:math';

import 'package:flutter/material.dart';

import 'package:diacritic/diacritic.dart';
import 'package:unorm_dart/unorm_dart.dart';

class MonogramText extends Text {
  MonogramText(
    String data, {
    super.key,
    super.locale,
    super.maxLines,
    super.overflow,
    super.selectionColor,
    super.semanticsLabel,
    super.softWrap,
    super.strutStyle,
    super.style,
    super.textAlign,
    super.textDirection,
    super.textHeightBehavior,
    super.textScaler,
    super.textWidthBasis,
  }) : super(_monogramify(data));

  static String _monogramify(String data) {
    // TODO: I actually really don't like this implementation ...
    final latinized = removeDiacritics(nfd(data.toUpperCase()));
    final wordified = latinized.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ');
    final split = wordified.split(' ').where((word) => word.isNotEmpty);
    if (split.length >= 2) {
      return split.first.substring(0, 1) + split.last.substring(0, 1);
    }
    final noWhitespace = wordified.replaceAll(RegExp(r'\s'), '');
    final fallback = noWhitespace.substring(0, min(2, noWhitespace.length));
    if (fallback.isEmpty) {
      return '<>';
    }
    return fallback;
  }
}
