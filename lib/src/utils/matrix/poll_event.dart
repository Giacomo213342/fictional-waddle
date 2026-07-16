import 'package:matrix/matrix.dart';

abstract class MatrixPollEventTypes {
  static const start = 'm.poll.start';
  static const response = 'm.poll.response';
  static const end = 'm.poll.end';
  static const unstableStart = 'org.matrix.msc3381.poll.start';
  static const unstableResponse = 'org.matrix.msc3381.poll.response';
  static const unstableEnd = 'org.matrix.msc3381.poll.end';
}

class MatrixPollAnswer {
  const MatrixPollAnswer({required this.id, required this.text});

  final String id;
  final String text;
}

extension MatrixPollEvent on Event {
  bool get isPollStart => const {
        MatrixPollEventTypes.start,
        MatrixPollEventTypes.unstableStart,
      }.contains(type);

  bool get isPollResponse => const {
        MatrixPollEventTypes.response,
        MatrixPollEventTypes.unstableResponse,
      }.contains(type);

  Map<String, dynamic>? get _pollContent {
    final poll =
        content['m.poll'] ?? content[MatrixPollEventTypes.unstableStart];
    return poll is Map ? Map<String, dynamic>.from(poll) : null;
  }

  String? get pollQuestion =>
      _plainText(_pollContent?['question']) ??
      _plainText(content['m.text']) ??
      _plainText(content['org.matrix.msc1767.text']);

  List<MatrixPollAnswer> get pollAnswers {
    final answers = _pollContent?['answers'];
    if (answers is! List) {
      return const [];
    }
    return answers
        .whereType<Map>()
        .map((answer) {
          final data = Map<String, dynamic>.from(answer);
          return MatrixPollAnswer(
            id: data['id']?.toString() ?? '',
            text: _plainText(data['m.text']) ??
                _plainText(data['org.matrix.msc1767.text']) ??
                data['id']?.toString() ??
                '',
          );
        })
        .where((answer) => answer.id.isNotEmpty)
        .toList();
  }

  String? get pollResponseTarget {
    final relation = content['m.relates_to'];
    if (relation is! Map) {
      return null;
    }
    return relation['event_id']?.toString();
  }

  List<String> get pollSelections {
    final unstableResponse = content[MatrixPollEventTypes.unstableResponse];
    final selections = content['m.selections'] ??
        (unstableResponse is Map ? unstableResponse['answers'] : null);
    return selections is List
        ? selections.map((selection) => selection.toString()).toList()
        : const [];
  }

  static String? _plainText(Object? value) {
    if (value is String) {
      return value;
    }
    if (value is Map) {
      return _plainText(value['m.text']) ??
          _plainText(value['org.matrix.msc1767.text']) ??
          value['body']?.toString();
    }
    if (value is List) {
      for (final representation in value) {
        final text = _plainText(representation);
        if (text != null && text.isNotEmpty) {
          return text;
        }
      }
    }
    return null;
  }
}

extension MatrixPollRoom on Room {
  Future<String?> sendPoll(String question, List<String> answers) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final pollAnswers = answers.indexed
        .map(
          (entry) => {
            'id': '$timestamp-${entry.$1}',
            'm.text': [
              {'body': entry.$2, 'mimetype': 'text/plain'},
            ],
          },
        )
        .toList();
    return sendEvent(
      {
        'm.poll': {
          'question': {
            'm.text': [
              {'body': question, 'mimetype': 'text/plain'},
            ],
          },
          'kind': 'm.disclosed',
          'max_selections': 1,
          'answers': pollAnswers,
        },
        'm.text': [
          {'body': question, 'mimetype': 'text/plain'},
        ],
      },
      type: MatrixPollEventTypes.start,
    );
  }

  Future<String?> sendPollResponse(Event poll, String answerId) {
    final unstable = poll.type == MatrixPollEventTypes.unstableStart;
    return sendEvent(
      {
        'm.relates_to': {
          'rel_type': 'm.reference',
          'event_id': poll.eventId,
        },
        if (unstable)
          MatrixPollEventTypes.unstableResponse: {
            'answers': [answerId],
          }
        else
          'm.selections': [answerId],
      },
      type: unstable
          ? MatrixPollEventTypes.unstableResponse
          : MatrixPollEventTypes.response,
    );
  }
}
