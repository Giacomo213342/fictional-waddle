import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../login.dart';

class PasswordLoginProvider extends StatefulWidget {
  const PasswordLoginProvider(this.controller, {super.key});

  final LoginController controller;

  @override
  State<PasswordLoginProvider> createState() => _PasswordLoginProviderState();
}

enum _LoginTypes { username, email }

class _PasswordLoginProviderState extends State<PasswordLoginProvider> {
  final userController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  _LoginTypes? selectedAuthentication;

  bool _showPassword = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        padding: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(width: 4, color: Theme.of(context).focusColor),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).loginPassword,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 16),
              Center(
                child: SegmentedButton<_LoginTypes?>(
                  emptySelectionAllowed: true,
                  multiSelectionEnabled: false,
                  segments: [
                    ButtonSegment(
                      value: _LoginTypes.username,
                      icon: const Icon(Icons.person),
                      label: Text(AppLocalizations.of(context).username),
                    ),
                    ButtonSegment(
                      value: _LoginTypes.email,
                      icon: const Icon(Icons.alternate_email),
                      label: Text(AppLocalizations.of(context).email),
                    ),
                  ],
                  selected: {selectedAuthentication},
                  onSelectionChanged: _setAuthentication,
                ),
              ),
              const SizedBox(height: 16),
              if (selectedAuthentication == _LoginTypes.username)
                TextFormField(
                  controller: userController,
                  keyboardType: TextInputType.name,
                  autofocus: true,
                  autocorrect: false,
                  validator: _mxidValidator,
                  inputFormatters: [
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) =>
                          newValue.copyWith(text: newValue.text.toLowerCase()),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).username,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    prefixText: '@',
                    suffixText: ':${widget.controller.homeserver.host}',
                  ),
                  textInputAction: TextInputAction.next,
                ),
              if (selectedAuthentication == _LoginTypes.email)
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  autocorrect: false,
                  validator: _mightBeMailValidator,
                  inputFormatters: [
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) =>
                          newValue.copyWith(text: newValue.text.toLowerCase()),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).email,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                ),
              const SizedBox(height: 16),
              if (selectedAuthentication != null)
                TextFormField(
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: !_showPassword,
                  autocorrect: false,
                  validator: _notEmptyValidator,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).password,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _togglePasswordVisibility,
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  onFieldSubmitted: (_) => _submitForm(),
                  textInputAction: TextInputAction.join,
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _setAuthentication(Set<_LoginTypes?> selection) =>
      setState(() => selectedAuthentication = selection.single);

  void _togglePasswordVisibility() =>
      setState(() => _showPassword = !_showPassword);

  Future<void> _submitForm() async {
    final valid = _formKey.currentState?.validate();
    if (valid != true) {
      return;
    }

    final identifier = selectedAuthentication == _LoginTypes.username
        ? AuthenticationUserIdentifier(user: userController.text)
        : AuthenticationThirdPartyIdentifier(
            medium: 'email',
            address: emailController.text,
          );

    final password = passwordController.text;
    await widget.controller.passwordLogin(identifier, password);
  }

  String? _mightBeMailValidator(String? value) {
    // we won't match mail addresses - there will always be false positives ...
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).pleaseProvideEmail;
    }
    // only check whether an$thing@some#host.@tld
    final regex = RegExp(r'^.+@.+\..+$');
    if (!regex.hasMatch(value)) {
      return AppLocalizations.of(context).emailMinimals;
    }
    return null;
  }

  String? _notEmptyValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).pleaseProvidePassword;
    }
    return null;
  }

  String? _mxidValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).pleaseProvideUsername;
    }
    final regex = RegExp(r'^[a-z0-9\._\/=+]+$');
    if (!regex.hasMatch(value)) {
      return AppLocalizations.of(context).mxidSyntax;
    }

    return null;
  }
}
