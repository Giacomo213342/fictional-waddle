import 'package:flutter/material.dart';

import '../../../scopes/sas_scope.dart';

class CompareSasDecimal extends StatelessWidget {
  const CompareSasDecimal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final verification = SasScope.of(context).verification;

    final sasNumbers = verification.sasNumbers;
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
    return Center(
      child: SelectableText.rich(
        TextSpan(children: spans),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
