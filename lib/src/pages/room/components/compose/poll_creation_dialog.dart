import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../utils/matrix/poll_event.dart';
import '../../../room_list/room_list_position_tracker.dart';

class PollCreationDialog extends StatefulWidget {
  const PollCreationDialog({super.key, required this.room});

  final Room room;

  @override
  State<PollCreationDialog> createState() => _PollCreationDialogState();
}

class _PollCreationDialogState extends State<PollCreationDialog> {
  final _question = TextEditingController();
  final List<TextEditingController> _answers = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _sending = false;

  @override
  void dispose() {
    _question.dispose();
    for (final answer in _answers) {
      answer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create poll'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _question,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            const SizedBox(height: 12),
            ..._answers.indexed.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entry.$2,
                        decoration: InputDecoration(
                          labelText: 'Answer ${entry.$1 + 1}',
                        ),
                      ),
                    ),
                    if (_answers.length > 2)
                      IconButton(
                        onPressed: () => _removeAnswer(entry.$1),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                  ],
                ),
              ),
            ),
            if (_answers.length < 6)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addAnswer,
                  icon: const Icon(Icons.add),
                  label: const Text('Add answer'),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _sending ? null : _send,
          child: _sending
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send poll'),
        ),
      ],
    );
  }

  void _addAnswer() {
    setState(() => _answers.add(TextEditingController()));
  }

  void _removeAnswer(int index) {
    final controller = _answers.removeAt(index);
    controller.dispose();
    setState(() {});
  }

  Future<void> _send() async {
    final question = _question.text.trim();
    final answers = _answers
        .map((answer) => answer.text.trim())
        .where((answer) => answer.isNotEmpty)
        .toList();
    if (question.isEmpty || answers.length < 2) return;
    setState(() => _sending = true);
    RoomListPositionTracker.markInteraction(widget.room);
    try {
      await widget.room.sendPoll(question, answers);
      if (mounted) Navigator.of(context).pop();
    } catch (error, stackTrace) {
      Logs().w('Unable to create poll.', error, stackTrace);
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to create poll. Try again.')),
      );
    }
  }
}
