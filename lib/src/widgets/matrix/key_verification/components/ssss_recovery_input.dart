import 'package:flutter/material.dart';

import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../ascii_progress_indicator.dart';
import '../../avatar_builder/mxc_avatar.dart';
import '../key_verification_request_widget.dart';

class SsssRecoveryInput extends StatefulWidget {
  const SsssRecoveryInput(
    this.request, {
    super.key,
    required this.onSubmit,
    required this.buttonBarBuilder,
    this.profile,
    this.client,
  });

  final KeyVerification request;
  final Profile? profile;
  final Client? client;
  final ButtonBarBuilder buttonBarBuilder;
  final ValueChanged<String> onSubmit;

  @override
  State<SsssRecoveryInput> createState() => _SsssRecoveryInputState();
}

class _SsssRecoveryInputState extends State<SsssRecoveryInput> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final client = widget.client;
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                if (profile != null && client != null)
                  MxcAvatar(
                    uri: profile.avatarUrl,
                    monogram: profile.displayName ?? profile.userId,
                    dimension: 64,
                  ),
                const SizedBox(height: 16),
                const AsciiProgressIndicator(),
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
