import 'package:flutter/material.dart';

import 'package:matrix_homeserver_recommendations/matrix_homeserver_recommendations.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../../../widgets/matrix/html/polycule_html_view.dart';
import '../../login/login.dart';

class BenchmarkWidget extends StatelessWidget {
  const BenchmarkWidget(this.result, {super.key});

  final HomeserverBenchmarkResult result;

  @override
  Widget build(BuildContext context) {
    final description = result.homeserver.description;
    return ListTile(
      title: Text(result.homeserver.baseUrl.host),
      subtitle: description != null
          ? PolyculeHtmlView(
              html: description,
            )
          : null,
      trailing: IconButton(
        tooltip: AppLocalizations.of(context).connect,
        icon: const Icon(Icons.rocket_launch),
        onPressed: () => context.pushMultiClient(
          LoginPage.makeRouteName(result.homeserver.baseUrl),
        ),
      ),
    );
  }
}
