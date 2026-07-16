Map<String, dynamic> buildPollResponseContent({
  required String pollEventId,
  required String answerId,
  required bool unstable,
}) {
  return {
    'm.relates_to': {
      'rel_type': 'm.reference',
      'event_id': pollEventId,
    },
    if (unstable)
      'org.matrix.msc3381.poll.response': {
        'answers': [answerId],
      }
    else
      'm.selections': [answerId],
  };
}
