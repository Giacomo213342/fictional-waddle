import 'package:matrix/matrix.dart';
import 'package:oidc/oidc.dart';

import '../password_cache_manager.dart';

typedef UiaTokenCallback = Future<String?> Function(UiaRequest request);
typedef UiaOidcTokenCallback = Future<OidcUser?> Function(
  UiaRequest request,
  OidcUserManager oidc,
);

class UiaHelper {
  const UiaHelper({
    required this.client,
    this.oidc,
    required this.request,
    required this.authenticationOidcCallback,
    required this.authenticationPasswordCallback,
  });

  final Client client;
  final OidcUserManager? oidc;
  final UiaRequest request;
  final UiaOidcTokenCallback authenticationOidcCallback;
  final UiaTokenCallback authenticationPasswordCallback;

  Future<void> respond() async {
    Logs().v('UIA stage: ${request.state}.');
    switch (request.state) {
      case UiaRequestState.done:
      case UiaRequestState.fail:
      case UiaRequestState.loading:
        return;
      case UiaRequestState.waitForUser:
        final oidc = this.oidc;
        if (request.nextStages.contains(LoginType.mLoginToken) &&
            oidc != null) {
          final user = await authenticationOidcCallback.call(request, oidc);
          if (user == null) {
            return;
          }
          final token = user.token.accessToken;
          if (token == null) {
            return;
          }
          final auth = AuthenticationToken(
            session: request.session,
            token: token,
          );
          await request.completeStage(auth);

          return;
        } else if (request.nextStages.contains(LoginType.mLoginPassword)) {
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
        } else {
          Logs().v('No compatible UIA stage found in ${request.nextStages}.');
        }
    }
  }
}
