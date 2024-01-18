import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/ascii_progress_indicator.dart';
import 'components/benchmark.dart';
import 'components/homeserver_input.dart';
import 'homeserver.dart';

class HomeserverView extends StatelessWidget {
  const HomeserverView(this.controller, {super.key});

  final HomeserverController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 786),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppLocalizations.of(context)!.homeserverHeadline,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    AppLocalizations.of(context)!.aMatrixClient,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 64),
                  const HomeserverInput(),
                  const Divider(),
                  ExpansionTile(
                    title:
                        Text(AppLocalizations.of(context)!.discoverHomeservers),
                    subtitle:
                        Text(AppLocalizations.of(context)!.newToMatrixLong),
                    onExpansionChanged:
                        controller.handleHomeserverListExpansion,
                    children: [
                      if (controller.recommendationsLoading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: AsciiProgressIndicator()),
                        ),
                      ...controller.recommendations
                          .map((e) => BenchmarkWidget(e)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
