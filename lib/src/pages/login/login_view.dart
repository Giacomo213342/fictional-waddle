import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../router/extensions/go_router_path_extension.dart';
import '../../widgets/ascii_progress_indicator.dart';
import '../../widgets/matrix/scopes/client_scope.dart';
import '../homeserver/homeserver.dart';
import 'components/providers/legacy_sso_login_provider.dart';
import 'components/providers/matrix_oidc_login_provider.dart';
import 'components/providers/password_login_provider.dart';
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

            final oidcFlows = data.$3.where(
              (flow) =>
                  flow.type == AuthenticationTypes.sso &&
                  flow.delegatedOidcCompatibility,
            );
            final legacySsoFlows = data.$3.where(
              (flow) =>
                  flow.type == AuthenticationTypes.sso &&
                  !flow.delegatedOidcCompatibility,
            );
            final legacyPasswordFlows = data.$3.where(
              (flow) => flow.type == LoginType.mLoginPassword,
            );
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
                    // only show OIDC if available
                    if (oidcFlows.isNotEmpty)
                      MatrixOidcLoginProvider(
                        discoveryInformation: data.$1,
                      )
                    // otherwise show all other possible flows
                    else ...[
                      // by spec this list will only have a single entry but
                      // I don't trust any homeserver
                      ...legacySsoFlows.map(
                        (flow) => LegacySSOProviderScope(
                          ssoFlow: flow,
                          child: const LegacySSOLoginProvider(),
                        ),
                      ),
                      if (legacyPasswordFlows.isNotEmpty)
                        const PasswordLoginProvider(),
                    ],
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
