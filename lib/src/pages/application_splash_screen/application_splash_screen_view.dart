import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../utils/assets.dart';
import 'components/fade_in_logo.dart';

class ApplicationSplashScreenView extends StatelessWidget {
  const ApplicationSplashScreenView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 128,
                child: Hero(
                  tag: Assets.logoCircle,
                  child: FadeInLogo(),
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
            ],
          ),
        ),
      );
}
