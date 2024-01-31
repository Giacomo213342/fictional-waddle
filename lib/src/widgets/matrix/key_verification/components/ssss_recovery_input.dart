import 'package:flutter/material.dart';

import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../key_verification_request_widget.dart';

class SsssRecoveryInput extends StatefulWidget {
  const SsssRecoveryInput(
    this.request, {
    super.key,
    required this.onSubmit,
    required this.buttonBarBuilder,
    this.profile,
  });

  final KeyVerification request;
  final Profile? profile;
  final ButtonBarBuilder buttonBarBuilder;
  final ValueChanged<String> onSubmit;

  @override
  State<SsssRecoveryInput> createState() => _SsssRecoveryInputState();
}

class _SsssRecoveryInputState extends State<SsssRecoveryInput> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              children: [
                // if (profile != null)
                // TODO : show user picture here
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(
                    AppLocalizations.of(context).waitingForVerificationFallback,
                  ),
                ),
                TextField(
                  controller: controller,
                  obscureText: true,
                  onEditingComplete: _submit,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: AppLocalizations.of(context).enterRecoveryPhrase,
                    suffixIcon: IconButton(
                      onPressed: _submit,
                      tooltip: AppLocalizations.of(context).next,
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ),
              ],
            ),
          ),
          widget.buttonBarBuilder.call(
            context,
            [
              ElevatedButton(
                onPressed: null,
                child: Text(AppLocalizations.of(context).previous),
              ),
              ElevatedButton(
                onPressed: _submit,
                child: Text(AppLocalizations.of(context).next),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _submit() {
    final key = controller.text.replaceAll(RegExp(r'\s'), '');
    if (key.isEmpty) {
      widget.onSubmit.call(key);
    }
  }
}
