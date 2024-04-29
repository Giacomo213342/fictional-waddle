import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:matrix/matrix_api_lite.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../router/extensions/go_router_path_extension.dart';
import '../../utils/matrix/matrix_state.dart';
import '../../utils/password_cache_manager.dart';
import '../homeserver/homeserver.dart';
import 'login_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.homeserver});

  static const routeName = '${HomeserverPage.routeName}/:$pathParameter';
  static const pathParameter = 'server';

  static String makeRouteName(Uri homeserver) {
    if (homeserver.isScheme('https')) {
      if (homeserver.hasPort) {
        return '${HomeserverPage.routeName}/${Uri.encodeComponent('${homeserver.host}:${homeserver.port}')}';
      }
      return '${HomeserverPage.routeName}/${homeserver.host}';
    } else {
      return '${HomeserverPage.routeName}/${Uri.encodeComponent(homeserver.toString())}';
    }
  }

  final Uri homeserver;

  @override
  State<LoginPage> createState() => LoginController();
}

class LoginController extends MatrixState<LoginPage> {
  bool loginLoading = false;

  Uri get homeserver => widget.homeserver;

  Future<(DiscoveryInformation?, GetVersionsResponse, List<LoginFlow>)?>?
      homeserverCheck;

  @override
  void initState() {
    homeserverCheck = Future<
        (
          DiscoveryInformation?,
          GetVersionsResponse,
          List<LoginFlow>
        )?>.value(client.checkHomeserver(homeserver))
      ..onError(_popHomeserverError);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => LoginView(this);

  FutureOr<(DiscoveryInformation?, GetVersionsResponse, List<LoginFlow>)?>
      _popHomeserverError(
    Object error,
    StackTrace stackTrace,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)
              .errorConnectingToHomeserver(homeserver.toString()),
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      context.go(HomeserverPage.routeName);
    });
    return null;
  }

  Future<void> passwordLogin(
    AuthenticationIdentifier identifier,
    String password,
  ) async {
    setState(() {
      loginLoading = true;
    });
    try {
      await client.login(
        LoginType.mLoginPassword,
        identifier: identifier,
        initialDeviceDisplayName: _generateDeviceDisplayName(),
        password: password,
      );
    } on MatrixException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).loginErrorMessage(e.errorMessage),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).loginError)),
        );
      }
    }
    PasswordCacheManager.cachedPassword = password;
    if (mounted) {
      setState(() {
        loginLoading = false;
      });
    }
  }

  String _generateDeviceDisplayName() {
    final platform = kIsWeb
        ? AppLocalizations.of(context).platformWeb
        : Platform.operatingSystem;

    return AppLocalizations.of(context).clientDisplayName(platform);
  }
}
