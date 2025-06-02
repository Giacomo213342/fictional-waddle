import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../widgets/matrix/client_manager/client_manager.dart';
import '../../widgets/matrix/client_manager/client_store.dart';
import 'application_splash_screen_view.dart';

class ApplicationSplashScreen extends StatefulWidget {
  const ApplicationSplashScreen({super.key});

  static const routeName = '/';

  @override
  State<ApplicationSplashScreen> createState() =>
      _ApplicationSplashScreenState();
}

class _ApplicationSplashScreenState extends State<ApplicationSplashScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _clientRedirect());
    super.initState();
  }

  @override
  Widget build(BuildContext context) => const ApplicationSplashScreenView();

  Future<void> _clientRedirect() async {
    final manager = ClientManager.of(context);
    await manager.store.waiForInitialization;
    if (!mounted) {
      return;
    }

    final client = manager.store.activeClients.value.first;
    context.go('/client/${client.clientName.clientIdentifier}');
  }
}
