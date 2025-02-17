import 'package:flutter/material.dart';

import 'package:matrix_homeserver_recommendations/matrix_homeserver_recommendations.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/ascii_progress_indicator.dart';
import 'benchmark.dart';

class HomeserverRecommendationCard extends StatefulWidget {
  const HomeserverRecommendationCard({super.key});

  @override
  State<HomeserverRecommendationCard> createState() =>
      _HomeserverRecommendationCardState();
}

class _HomeserverRecommendationCardState
    extends State<HomeserverRecommendationCard> {
  final recommendationParser = const JoinmatrixOrgParser();

  bool _loading = false;
  List<HomeserverBenchmarkResult> recommendations = [];
  Duration _timeout = const Duration(seconds: 5);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        AppLocalizations.of(context).discoverHomeservers,
      ),
      subtitle: Text(
        AppLocalizations.of(context).newToMatrixLong,
      ),
      onExpansionChanged: _handleHomeserverListExpansion,
      children: [
        if (_loading)
          Focus(
            autofocus: true,
            child: Semantics(
              hint: AppLocalizations.of(context).loadingHomeservers,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: AsciiProgressIndicator(),
                ),
              ),
            ),
          ),
        ...recommendations.map((e) => BenchmarkWidget(e)),
      ],
    );
  }

  Future<void> _handleHomeserverListExpansion(bool expanded) async {
    if (expanded && recommendations.isEmpty && !_loading) {
      return loadHomeserverRecommendations();
    }
  }

  Future<void> loadHomeserverRecommendations() async {
    setState(() => _loading = true);
    try {
      final servers = await recommendationParser.fetchHomeservers();
      servers.removeWhere((element) => element.registrationAllowed != true);
      final result = await HomeserverListProvider.benchmarkHomeserver(
        servers,
        timeout: _timeout,
      );
      setState(() {
        recommendations = result;
      });
    } catch (_) {
      _timeout = const Duration(seconds: 30);
    }
    setState(() => _loading = false);
  }
}
