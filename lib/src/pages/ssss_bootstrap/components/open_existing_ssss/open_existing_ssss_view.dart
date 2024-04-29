import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import 'open_existing_ssss.dart';

class OpenExistingSsssView extends StatelessWidget {
  const OpenExistingSsssView({
    super.key,
    required this.controller,
  });

  final OpenExistingSsssController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
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
        ElevatedButton(
          onPressed: controller.verifyWithDevice,
          child: Text(AppLocalizations.of(context).verifyWithOtherDevice),
        ),
        const Divider(),
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
        ElevatedButton(
          onPressed: controller.submit,
          child: Text(AppLocalizations.of(context).verifyWithPassphrase),
        ),
        const SizedBox(
          height: 48,
        ),
        Text(AppLocalizations.of(context).verifyMethodsNotAvailable),
        TextButton(
          onPressed: controller.askWipeSsss,
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(AppLocalizations.of(context).wipeAccount),
        ),
      ],
    );
  }
}
