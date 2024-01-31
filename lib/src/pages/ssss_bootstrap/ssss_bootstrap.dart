import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/encryption.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../utils/matrix/matrix_state.dart';
import '../fatal_error/fatal_error_page.dart';
import '../room_list/room_list.dart';
import 'components/ask_wipe_ssss_widget.dart';
import 'ssss_bootstrap_view.dart';

class SsssBootstrapPage extends StatefulWidget {
  const SsssBootstrapPage({super.key, this.passphrase});

  final String? passphrase;

  static const routeName = '/bootstrap';

  @override
  State<SsssBootstrapPage> createState() => SsssBootstrapController();
}

class SsssBootstrapController extends MatrixState<SsssBootstrapPage> {
  Bootstrap? bootstrap;

  bool _wipeSsss = false;

  KeyVerification? keyVerificationRequest;

  static const _ssssKeyStorage = 'ssss_key';

  @override
  void initState() {
    _startBootstrap();
    super.initState();
  }

  void _startBootstrap() {
    _nextStage(
      () => client.encryption?.bootstrap(onUpdate: _handleBootstrapStage),
    );
  }

  void _nextStage(void Function() next) =>
      WidgetsBinding.instance.addPostFrameCallback((_) => next.call());

  void _handleBootstrapStage(Bootstrap bootstrap) {
    log('Bootstrap state: ${bootstrap.state}', name: 'SSSS');
    // print the key for debugging as long as we don't support guided key backup
    // print(bootstrap.newSsssKey?.recoveryKey);
    switch (bootstrap.state) {
      case BootstrapState.loading:
        break;
      case BootstrapState.askNewSsss:
        _nextStage(
          () => bootstrap
              .newSsss(widget.passphrase)
              .then((_) => _storeCrossSigningKey()),
        );
        break;
      case BootstrapState.askSetupCrossSigning:
        _nextStage(
          () => bootstrap.askSetupCrossSigning(
            setupMasterKey: true,
            setupSelfSigningKey: true,
            setupUserSigningKey: true,
          ),
        );
        break;
      case BootstrapState.askWipeSsss:
        _nextStage(() => bootstrap.wipeSsss(_wipeSsss));
        break;
      case BootstrapState.askUseExistingSsss:
        // in case of passphrase migration, don't use the present SSSS
        final bool useExistingSsss = widget.passphrase == null;
        _nextStage(() => bootstrap.useExistingSsss(useExistingSsss));
        break;
      case BootstrapState.askUnlockSsss:
        _nextStage(() => bootstrap.unlockedSsss());
        break;
      case BootstrapState.askBadSsss:
        _nextStage(() => bootstrap.ignoreBadSecrets(_wipeSsss));
        break;
      case BootstrapState.openExistingSsss:
        break;
      case BootstrapState.askWipeCrossSigning:
        _nextStage(() => bootstrap.wipeCrossSigning(_wipeSsss));
        break;
      case BootstrapState.askWipeOnlineKeyBackup:
        _nextStage(() => bootstrap.wipeOnlineKeyBackup(_wipeSsss));
        break;
      case BootstrapState.askSetupOnlineKeyBackup:
        _nextStage(() => bootstrap.askSetupOnlineKeyBackup(true));
        break;
      case BootstrapState.error:
        _nextStage(() => context.go(FatalErrorPage.routeName));
        break;
      case BootstrapState.done:
        if (widget.passphrase != null) {
          context.pop();
          return;
        }
        _nextStage(() => context.go(RoomListPage.routeName));
        break;
    }
    setState(() => this.bootstrap = bootstrap);
  }

  @override
  Widget build(BuildContext context) => SsssBootstrapPageView(this);

  Future<void> interactiveSasVerification() async {
    final user = client.userID!;

    keyVerificationRequest =
        await client.userDeviceKeys[user]?.startVerification();
    setState(() {});
  }

  Future<void> askWipeSsss() async {
    final response = await AskWipeSsssWidget.show(context);

    if (response == false || response == null) {
      return;
    }

    setState(() {
      _wipeSsss = response;
    });

    _startBootstrap();
  }

  void sasVerificationSuccessful() {
    setState(() {
      keyVerificationRequest = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(RoomListPage.routeName);
    });
  }

  void cancelSasVerification() {
    keyVerificationRequest?.cancel();
    setState(() {
      keyVerificationRequest = null;
    });
  }

  Future<void> openExistingSsss(String key) async {
    if (bootstrap?.state != BootstrapState.openExistingSsss) {
      // We were sometimes already in the BootstrapState.openExistingSsss, which
      // caused an error to be thrown in the matrix dart sdk that we are in the
      // wrong bootstrap state, when we tried to set useExistingSsss to true
      bootstrap?.useExistingSsss(true);
    }
    // cross-signing the key
    try {
      await bootstrap?.newSsssKey?.unlock(keyOrPassphrase: key);
      await bootstrap?.openExistingSsss();
      await bootstrap?.client.encryption!.crossSigning
          .selfSign(keyOrPassphrase: key);
    } on InvalidPassphraseException {
      if (mounted) {
        await showAdaptiveDialog(
          context: context,
          builder: (context) => AlertDialog.adaptive(
            title: Text(AppLocalizations.of(context).errorTryAgain),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(AppLocalizations.of(context).close),
              ),
            ],
          ),
        );
      }
      return;
    }
  }

  Future<void> _storeCrossSigningKey() async {
    const storage = FlutterSecureStorage();

    if (widget.passphrase != null) {
      storage.delete(key: _ssssKeyStorage);
      return;
    }

    final key = bootstrap?.newSsssKey?.recoveryKey;
    if (key == null) {
      return;
    }

    await storage.write(key: _ssssKeyStorage, value: key);
  }
}
