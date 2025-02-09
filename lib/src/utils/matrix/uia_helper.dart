import 'package:matrix/matrix.dart';

import '../password_cache_manager.dart';

typedef UiaTokenCallback = Future<String?> Function(UiaRequest request);
typedef UiaOidcAccountManagementCallback = Future<bool?> Function(
  UiaRequest request,
  OidcAccountManagementActions action,
);

class UiaHelper {
  const UiaHelper({
    required this.client,
    required this.request,
    required this.authenticationOidcAccountManagementCallback,
    required this.authenticationPasswordCallback,
  });

  final Client client;
  final UiaRequest request;
  final UiaOidcAccountManagementCallback
      authenticationOidcAccountManagementCallback;
  final UiaTokenCallback authenticationPasswordCallback;

  Future<void> respond() async {
    Logs().v('UIA stage: ${request.state}.');
    switch (request.state) {
      case UiaRequestState.done:
      case UiaRequestState.fail:
      case UiaRequestState.loading:
        return;
      case UiaRequestState.waitForUser:
        final accountAction = OidcAccountManagementActions.values
            .where((action) => request.nextStages.contains(action.action))
            .singleOrNull;

        /// OIDC pseudo stages
        if (accountAction != null) {
          final response =
              await authenticationOidcAccountManagementCallback.call(
            request,
            accountAction,
          );
          if (response != true) {
            return;
          }

          final auth = AuthenticationData(
            session: request.session,
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
