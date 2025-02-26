import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../ssss_bootstrap.dart';
import 'open_existing_ssss_view.dart';

class OpenExistingSsssWidget extends StatefulWidget {
  const OpenExistingSsssWidget(
    this.controller, {
    super.key,
  });

  final SsssBootstrapController controller;

  @override
  State<OpenExistingSsssWidget> createState() => OpenExistingSsssController();
}

class OpenExistingSsssController extends State<OpenExistingSsssWidget> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final passphraseFormKey = GlobalKey<FormState>();

  bool obscurePassphrase = true;

  bool get disableSas => widget.controller.widget.disableSas;

  final TextEditingController passphraseTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return OpenExistingSsssView(
      controller: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    passphraseTextEditingController.dispose();
  }

  void toggleObscurePassphrase() {
    setState(() {
      obscurePassphrase = !obscurePassphrase;
    });
  }

  String? passphraseFormValidation(String? passphrase) {
    if (passphrase == null || passphrase.isEmpty) {
      return AppLocalizations.of(context).passphraseNotEmpty;
    }
    return null;
  }

  Future<void> verifyWithDevice() {
    return widget.controller.interactiveSasVerification();
  }

  void submit() {
    final formState = passphraseFormKey.currentState;
    if (formState?.validate() == false) {
      return;
    }
    final key =
        passphraseTextEditingController.text.replaceAll(RegExp(r'\s'), '');
    if (key.isEmpty) {
      return;
    }
    widget.controller.openExistingSsss(key);
  }

  void askWipeSsss() {
    widget.controller.askWipeSsss();
  }
}
