import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../ascii_progress_indicator.dart';
import '../../../future_callback_builder.dart';
import '../../scopes/sas_scope.dart';
import 'sas_profile.dart';
import 'sas_verification_bottom_bar.dart';

class SsssRecoveryInput extends StatefulWidget {
  const SsssRecoveryInput({
    super.key,
  });

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
                const SasProfile(),
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
          SasVerificationBottomBar(
            children: [
              FutureCallbackBuilder(
                callback: () =>
                    SasScope.of(context).verification.cancel('m.user'),
                builder: (context, callback, loading) => loading
                    ? const AsciiProgressIndicator()
                    : ElevatedButton(
                        onPressed: callback,
                        child: Text(AppLocalizations.of(context).cancel),
                      ),
              ),
              FutureCallbackBuilder(
                callback: _submit,
                builder: (context, callback, loading) => loading
                    ? const AsciiProgressIndicator()
                    : ElevatedButton(
                        onPressed: callback,
                        child: Text(AppLocalizations.of(context).next),
                      ),
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

  Future<void> _submit() async {
    final key = controller.text.replaceAll(RegExp(r'\s'), '');
    if (key.isEmpty) {
      await SasScope.of(context).verification.openSSSS(keyOrPassphrase: key);
    }
  }
}
