import 'package:flutter/material.dart';

import 'package:matrix_homeserver_recommendations/matrix_homeserver_recommendations.dart';

import '../../utils/about_dialog.dart';
import 'homeserver_view.dart';

class HomeserverPage extends StatefulWidget {
  const HomeserverPage({super.key});

  static const routeName = '/login';

  @override
  State<HomeserverPage> createState() => HomeserverController();
}

class HomeserverController extends State<HomeserverPage> {
  final recommendationParser = const JoinmatrixOrgParser();

  bool recommendationsLoading = false;
  List<HomeserverBenchmarkResult> recommendations = [];

  @override
  Widget build(BuildContext context) => HomeserverView(this);

  Future<void> handleHomeserverListExpansion(bool expanded) async {
    if (expanded && recommendations.isEmpty) {
      return loadHomeserverRecommendations();
    }
  }

  Future<void> loadHomeserverRecommendations() async {
    setState(() => recommendationsLoading = true);
    try {
      final servers = await recommendationParser.fetchHomeservers();
      servers.removeWhere((element) => element.registrationAllowed != true);
      final result = await HomeserverListProvider.benchmarkHomeserver(servers);
      setState(() {
        recommendations = result;
      });
    } catch (_) {}
    setState(() => recommendationsLoading = false);
  }

  void showAboutDialog() {
    showInfoDialog(context);
  }
}
