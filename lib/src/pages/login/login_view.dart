import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../router/extensions/go_router_path_extension.dart';
import '../../widgets/ascii_progress_indicator.dart';
import '../../widgets/matrix/scopes/client_scope.dart';
import '../homeserver/homeserver.dart';
import 'components/matrix_oidc_login_provider.dart';
import 'components/password_login_provider.dart';
import 'login.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeserver = LoginScope.of(context).homeserver;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FutureBuilder<
            (DiscoveryInformation?, GetVersionsResponse, List<LoginFlow>)?>(
          future: ClientScope.of(context).client.checkHomeserver(homeserver),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).errorConnectingToHomeserver(
                        homeserver.toString(),
                      ),
                    ),
                  ),
                );
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                context.goMultiClient(HomeserverPage.routeName);
              });
            }
            final data = snapshot.data;

            if (data == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AsciiProgressIndicator(),
                    const SizedBox(height: 32),
                    Text(
                      AppLocalizations.of(context).connectingToHomeserver(
                        homeserver.toString(),
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 786),
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  children: [
                    Text(
                      AppLocalizations.of(context)
                          .welcomeToHomeserver(homeserver.host),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    if (data.$3.any(
                      (flow) =>
                          flow.type == AuthenticationTypes.sso &&
                          flow.delegatedOidcCompatibility,
                    ))
                      MatrixOidcLoginProvider(
                        discoveryInformation: data.$1,
                      )
                    else if (data.$3.any(
                      (flow) => flow.type == LoginType.mLoginPassword,
                    ))
                      const PasswordLoginProvider(),
                    if (data.$3.any(
                      (flow) =>
                          flow.type == AuthenticationTypes.sso &&
                          !flow.delegatedOidcCompatibility,
                    ))
                      const ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text(
                          'Legacy SSO login is not implemented yet.',
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
