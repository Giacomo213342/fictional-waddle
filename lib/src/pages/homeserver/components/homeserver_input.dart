import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../../login/login.dart';

class HomeserverInput extends StatefulWidget {
  const HomeserverInput({super.key});

  @override
  State<HomeserverInput> createState() => _HomeserverInputState();
}

class _HomeserverInputState extends State<HomeserverInput> {
  final formKey = GlobalKey<FormState>();

  final controller = TextEditingController();

  Uri _parseHomeserverInput(String input) {
    if (input.startsWith(RegExp(r'http(s)?://'))) {
      return Uri.parse(input);
    } else {
      return Uri.https(input);
    }
  }

  String? _homeserverValidator(String? input) {
    if (input == null || input.isEmpty) {
      return AppLocalizations.of(context).pleaseProvideHomeserver;
    }
    try {
      _parseHomeserverInput(input);
      return null;
    } catch (e) {
      return AppLocalizations.of(context).homeserverNotValid;
    }
  }

  Future<void> _checkHomeserver() async {
    final valid = formKey.currentState?.validate();

    if (valid != true) {
      return;
    }

    final input = controller.text;
    final uri = _parseHomeserverInput(input);

    context.pushMultiClient(LoginPage.makeRouteName(uri));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFormField(
        controller: controller,
        autofocus: kIsWeb ||
            Platform.isLinux ||
            Platform.isMacOS ||
            Platform.isWindows,
        autocorrect: false,
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.go,
        cursorWidth: 10,
        validator: _homeserverValidator,
        onFieldSubmitted: (_) => _checkHomeserver(),
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
          ),
          prefixText: 'https://',
          suffixIcon: IconButton(
            padding: const EdgeInsets.all(16.0),
            tooltip: AppLocalizations.of(context).connect,
            icon: const Icon(Icons.rocket_launch),
            onPressed: _checkHomeserver,
          ),
          labelText: AppLocalizations.of(context).connectToHomeserver,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
