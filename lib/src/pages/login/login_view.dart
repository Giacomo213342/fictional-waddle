import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/ascii_progress_indicator.dart';
import 'components/password_login_provider.dart';
import 'login.dart';

class LoginView extends StatelessWidget {
  const LoginView(this.controller, {super.key});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FutureBuilder(
          future: controller.homeserverCheck,
          builder: (context, snapshot) {
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
                        controller.homeserver.toString(),
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
                          .welcomeToHomeserver(controller.homeserver.host),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      AppLocalizations.of(context).howWouldYouLikeToConnect,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (!controller.loginLoading) ...[
                      if (data.$3.any(
                        (flow) => flow.type == LoginType.mLoginPassword,
                      ))
                        PasswordLoginProvider(controller),
                      if (data.$3.any(
                        (flow) => flow.type == AuthenticationTypes.sso,
                      ))
                        const ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text(
                            'SSO login is not implemented yet. Coming soon.',
                          ),
                        ),
                      const SizedBox(
                        height: 32,
                        child: Divider(),
                      ),
                      const Text(
                        'Login flows we don\'t support :',
                      ),
                      ...data.$3
                          .where(
                            (element) =>
                                element.type != AuthenticationTypes.sso &&
                                element.type != LoginType.mLoginPassword &&
                                element.type != LoginType.mLoginToken,
                          )
                          .map(
                            (e) => Text(e.type.toString()),
                          ),
                    ] else
                      const Center(
                        child: AsciiProgressIndicator(),
                      ),
                  ],
                ),
              ),
            );

            // errors are handled in the [controller]
          },
        ),
      ),
    );
  }
}
