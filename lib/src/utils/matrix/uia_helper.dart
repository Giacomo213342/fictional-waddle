import 'package:matrix/matrix.dart';

import '../password_cache_manager.dart';

typedef UiaTokenCallback = Future<String?> Function(UiaRequest request);

class UiaHelper {
  const UiaHelper({
    required this.client,
    required this.request,
    required this.authenticationPasswordCallback,
  });

  final Client client;
  final UiaRequest request;
  final UiaTokenCallback authenticationPasswordCallback;

  Future<void> respond() async {
    Logs().v('UIA stage: ${request.state}.');
    switch (request.state) {
      case UiaRequestState.done:
      case UiaRequestState.fail:
      case UiaRequestState.loading:
        return;
      case UiaRequestState.waitForUser:
        if (request.nextStages.isEmpty) {
          return;
        }
        if (!request.nextStages.contains(LoginType.mLoginPassword)) {
          Logs().v('No compatible UIA stage found in ${request.nextStages}.');
          return;
        }

        final cachedPassword = PasswordCacheManager.cachedPassword;

        final password = cachedPassword ??
            await authenticationPasswordCallback.call(request);
        if (password == null) {
          return;
        }
        final auth = AuthenticationPassword(
          session: request.session,
          password: password,
          identifier: AuthenticationUserIdentifier(user: client.userID!),
        );
        await request.completeStage(auth);
        if (request.error != null) {
          PasswordCacheManager.cachedPassword = password;
        }
        return;
    }
  }
}
