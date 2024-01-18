import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/ascii_progress_indicator.dart';
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
                      AppLocalizations.of(context)!.connectingToHomeserver(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Login is not implemented yet. Coming soon.'),
                    ),
                    const Divider(),
                    Text(
                      'Login flows :',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    ...data.loginFlows.map(
                      (e) => Text(e.type.toString()),
                    ),
                    Text(
                      'Unstable features :',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    ...(data.versions.unstableFeatures ?? {})
                        .keys
                        .map((e) => Text(e)),
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
