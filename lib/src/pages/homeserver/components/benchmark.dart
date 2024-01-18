import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix_homeserver_recommendations/matrix_homeserver_recommendations.dart';

import '../../login/login.dart';

class BenchmarkWidget extends StatelessWidget {
  const BenchmarkWidget(this.result, {super.key});

  final HomeserverBenchmarkResult result;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(result.homeserver.baseUrl.host),
      trailing: IconButton(
        tooltip: AppLocalizations.of(context)!.connect,
        icon: const Icon(Icons.rocket_launch),
        onPressed: () => context.push(
          LoginPage.makeRouteName(result.homeserver.baseUrl),
        ),
      ),
    );
  }
}
