import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../widgets/center_card.dart';
import '../../../../widgets/labeled_divider.dart';
import 'open_existing_ssss.dart';

class OpenExistingSsssView extends StatelessWidget {
  const OpenExistingSsssView({
    super.key,
    required this.controller,
  });

  final OpenExistingSsssController controller;

  @override
  Widget build(BuildContext context) {
    return CenterCard(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          Focus(
            autofocus: true,
            child: ListTile(
              leading: const Icon(Icons.security),
              title: Text(
                AppLocalizations.of(context).verifyLogin,
                style: Theme.of(context).textTheme.headlineLarge!,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).waitingForVerificationFallback,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton.extended(
                onPressed: controller.verifyWithDevice,
                icon: const Icon(Icons.phonelink),
                label: Text(
                  AppLocalizations.of(context).verifyWithOtherDevice,
                ),
              ),
            ),
          ),
          const LabeledDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              AppLocalizations.of(context).verifyWithPassphrase,
              style: Theme.of(context).textTheme.titleLarge!,
            ),
          ),
          Form(
            key: controller.passphraseFormKey,
            child: TextFormField(
              controller: controller.passphraseTextEditingController,
              obscureText: controller.obscurePassphrase,
              onEditingComplete: controller.submit,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              validator: controller.passphraseFormValidation,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: AppLocalizations.of(context).enterRecoveryPhrase,
                suffixIcon: IconButton(
                  tooltip: AppLocalizations.of(context).togglePassword,
                  onPressed: controller.toggleObscurePassphrase,
                  icon: controller.obscurePassphrase
                      ? const Icon(Icons.visibility)
                      : const Icon(Icons.visibility_off),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: controller.submit,
                icon: const Icon(Icons.lock_open),
                label: Text(
                  AppLocalizations.of(context).verifyWithPassphrase,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 32,
            child: LabeledDivider(),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: Text(
              AppLocalizations.of(context).verifyMethodsNotAvailable,
            ),
            subtitle: Text(
              AppLocalizations.of(context).resetAccountWarning,
            ),
            trailing: TextButton(
              onPressed: controller.askWipeSsss,
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(AppLocalizations.of(context).wipeAccount),
            ),
            textColor: Theme.of(context).colorScheme.error,
            iconColor: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }
}
