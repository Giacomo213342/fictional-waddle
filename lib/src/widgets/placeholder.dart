import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../utils/assets.dart';

class PolyculePlaceholder extends StatelessWidget {
  const PolyculePlaceholder({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
        excludeSemantics: true,
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 256,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox.square(
                    dimension: 128,
                    child: Image.asset(
                      Assets.rosahajPeek.name,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context).appName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Row(
                    children: [
                      const Expanded(
                        flex: 1,
                        child: SizedBox(),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          AppLocalizations.of(context).aMatrixClient,
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
