import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';

class LogRow extends StatefulWidget {
  const LogRow(this.event, {super.key});

  final LogEvent event;

  @override
  State<LogRow> createState() => _LogRowState();
}

class _LogRowState extends State<LogRow> {
  bool expand = false;

  static const _maxLines = 10;

  String get text {
    String text = widget.event.title;
    if (widget.event.exception != null) {
      text += '\n${widget.event.exception}';
    }
    if (widget.event.stackTrace != null) {
      text += '\n${widget.event.stackTrace}';
    }
    return text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      key: ValueKey(text),
      duration: const Duration(milliseconds: 250),
      child: InkWell(
        onTap: _toggleExpansion,
        onLongPress: _copyError,
        child: Text(
          text,
          maxLines: expand ? null : _maxLines,
          style: TextStyle(
            color: switch (widget.event.level) {
              Level.wtf => Colors.purple,
              Level.error => Colors.red,
              Level.warning => Colors.orange,
              Level.info => Colors.green,
              Level.debug => Colors.blue,
              Level.verbose => null,
            },
            overflow: TextOverflow.fade,
          ),
        ),
      ),
    );
  }

  void _toggleExpansion() {
    setState(() {
      expand = !expand;
    });
  }

  void _copyError() {
    Clipboard.setData(ClipboardData(text: text));
  }
}
