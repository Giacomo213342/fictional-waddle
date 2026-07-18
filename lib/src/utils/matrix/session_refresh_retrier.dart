import 'dart:async';

import 'package:matrix/matrix.dart';

typedef SessionRefreshAttempt = Future<void> Function();
typedef SessionRefreshDelay = Future<void> Function(Duration duration);
typedef SessionRefreshRoundListener = void Function(
  Object error,
  StackTrace stackTrace,
  int exhaustedRounds,
);

/// Keeps a Matrix session alive while token refresh is temporarily unavailable.
///
/// The Matrix SDK logs out and clears the local session if its soft-logout
/// callback throws. For that reason only a homeserver `M_UNKNOWN_TOKEN`
/// response is allowed to escape this retrier. Network failures, timeouts and
/// other server errors remain retryable indefinitely.
class SessionRefreshRetrier {
  const SessionRefreshRetrier({
    this.retriesPerRound = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
    this.roundDelay = const Duration(minutes: 1),
    this.delay = Future<void>.delayed,
    this.onRoundExhausted,
  })  : assert(retriesPerRound >= 0),
        assert(retriesPerRound == 0 || retryDelays.length > 0);

  final int retriesPerRound;
  final List<Duration> retryDelays;
  final Duration roundDelay;
  final SessionRefreshDelay delay;
  final SessionRefreshRoundListener? onRoundExhausted;

  static bool isDefinitiveInvalidSession(Object error) =>
      error is MatrixException && error.error == MatrixError.M_UNKNOWN_TOKEN;

  Future<void> run(SessionRefreshAttempt refresh) async {
    var exhaustedRounds = 0;
    while (true) {
      for (var attempt = 0; attempt <= retriesPerRound; attempt++) {
        try {
          await refresh();
          return;
        } catch (error, stackTrace) {
          if (isDefinitiveInvalidSession(error)) rethrow;
          if (attempt < retriesPerRound) {
            final delayIndex =
                attempt < retryDelays.length ? attempt : retryDelays.length - 1;
            await delay(retryDelays[delayIndex]);
            continue;
          }
          exhaustedRounds++;
          onRoundExhausted?.call(error, stackTrace, exhaustedRounds);
        }
      }
      await delay(roundDelay);
    }
  }
}
