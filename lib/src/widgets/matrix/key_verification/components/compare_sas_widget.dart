import 'package:flutter/material.dart';

import 'package:matrix/encryption.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../key_verification_request_widget.dart';

class CompareSasWidget extends StatelessWidget {
  const CompareSasWidget(
    this.request, {
    super.key,
    this.onAccept,
    this.onReject,
    required this.buttonBarBuilder,
  });

  final KeyVerification request;
  final ButtonBarBuilder buttonBarBuilder;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final sasNumbers = request.sasNumbers;
    List<TextSpan> spans = [];
    final numberColor = Theme.of(context).colorScheme.primary;
    final dashColor = Theme.of(context).colorScheme.tertiary;

    for (final numBlock in sasNumbers) {
      spans.add(
        TextSpan(
          text: numBlock.toString(),
          style: TextStyle(color: numberColor),
        ),
      );
      spans.add(
        TextSpan(
          text: ' - ',
          style: TextStyle(color: dashColor),
        ),
      );
    }
    spans.removeLast();
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context).compareSasNumbers,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Center(
                  child: SelectableText.rich(
                    TextSpan(children: spans),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context).compareSasExplanation),
              ],
            ),
          ),
          buttonBarBuilder.call(
            context,
            [
              ElevatedButton(
                onPressed: onReject?.call,
                child: Text(AppLocalizations.of(context).noMatch),
              ),
              ElevatedButton(
                onPressed: onAccept?.call,
                child: Text(AppLocalizations.of(context).keysMatch),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
