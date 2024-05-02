import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return SelectableText(event.text);
  }
}
